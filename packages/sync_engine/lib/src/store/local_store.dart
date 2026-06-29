import 'package:drift/drift.dart';
import 'package:sync_engine/src/db/sync_database.dart' show SyncDatabase, SyncMetadataCompanion;
import 'package:sync_engine/src/models/remote_change.dart';
import 'package:sync_engine/src/models/sync_operation.dart';
import 'package:sync_engine/src/models/sync_record.dart';
import 'package:sync_engine/src/models/sync_record_status.dart';
import 'package:uuid/uuid.dart';

class LocalStore {
  LocalStore(this._db);

  final SyncDatabase _db;
  final _uuid = const Uuid();

  Stream<List<SyncRecord>> watch({String? eventType}) {
    final query = _db.select(_db.syncRecords)
      ..orderBy([(row) => OrderingTerm.desc(row.editedAt)]);

    if (eventType != null) {
      query.where((row) => row.eventType.equals(eventType));
    }

    return query.watch().map((rows) => rows.map(SyncRecord.fromRow).toList());
  }

  Future<SyncRecord?> findByLocalId(String localId) async {
    final row = await (_db.select(_db.syncRecords)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
    return row == null ? null : SyncRecord.fromRow(row);
  }

  Future<SyncRecord> create({
    required String eventType,
    required Map<String, dynamic> data,
    String? localId,
  }) async {
    final now = DateTime.now().toUtc();
    final record = SyncRecord(
      localId: localId ?? _uuid.v4(),
      eventType: eventType,
      operation: SyncOperation.create,
      data: data,
      syncStatus: SyncRecordStatus.pending,
      createdAt: now,
      editedAt: now,
    );

    await _db.into(_db.syncRecords).insert(record.toCompanion());
    return record;
  }

  Future<SyncRecord> update({
    required String localId,
    required Map<String, dynamic> data,
  }) async {
    final existing = await findByLocalId(localId);
    if (existing == null) {
      throw StateError('Record not found: $localId');
    }

    final now = DateTime.now().toUtc();
    final operation = existing.serverId == null
        ? SyncOperation.create
        : SyncOperation.update;

    final updated = existing.copyWith(
      data: data,
      operation: operation,
      syncStatus: SyncRecordStatus.pending,
      editedAt: now,
    );

    await _db.update(_db.syncRecords).replace(updated.toCompanion());
    return updated;
  }

  Future<SyncRecord> markDeleted(String localId) async {
    final existing = await findByLocalId(localId);
    if (existing == null) {
      throw StateError('Record not found: $localId');
    }

    final now = DateTime.now().toUtc();
    final updated = existing.copyWith(
      operation: SyncOperation.delete,
      syncStatus: SyncRecordStatus.pending,
      editedAt: now,
    );

    await _db.update(_db.syncRecords).replace(updated.toCompanion());
    return updated;
  }

  Future<List<SyncRecord>> pendingRecords() async {
    final rows = await (_db.select(_db.syncRecords)
          ..where((t) => t.syncStatus.equals(SyncRecordStatus.pending.name))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(SyncRecord.fromRow).toList();
  }

  Future<void> applyPushSuccess(SyncRecord record, DateTime syncedAt, {String? serverId, Map<String, dynamic>? data}) async {
    if (record.operation == SyncOperation.delete) {
      await (_db.delete(_db.syncRecords)..where((t) => t.localId.equals(record.localId))).go();
      return;
    }

    final merged = record.copyWith(
      serverId: serverId ?? record.serverId,
      data: data ?? record.data,
      syncStatus: SyncRecordStatus.synced,
      lastSyncedAt: syncedAt,
      retryCount: 0,
      operation: SyncOperation.update,
    );

    await _db.update(_db.syncRecords).replace(merged.toCompanion());
  }

  Future<void> markFailed(SyncRecord record) async {
    await _db.update(_db.syncRecords).replace(
          record.copyWith(syncStatus: SyncRecordStatus.failed).toCompanion(),
        );
  }

  Future<void> markConflict(SyncRecord record) async {
    await _db.update(_db.syncRecords).replace(
          record.copyWith(syncStatus: SyncRecordStatus.conflict).toCompanion(),
        );
  }

  Future<void> incrementRetry(SyncRecord record) async {
    await _db.update(_db.syncRecords).replace(
          record.copyWith(retryCount: record.retryCount + 1).toCompanion(),
        );
  }

  Future<DateTime?> lastPullAt(String eventType) async {
    final key = 'pull:$eventType';
    final row = await (_db.select(_db.syncMetadata)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row == null ? null : DateTime.parse(row.value).toUtc();
  }

  Future<void> setLastPullAt(String eventType, DateTime at) async {
    final key = 'pull:$eventType';
    await _db.into(_db.syncMetadata).insertOnConflictUpdate(
          SyncMetadataCompanion.insert(key: key, value: at.toUtc().toIso8601String()),
        );
  }

  Future<void> applyRemoteChange(RemoteChange change) async {
    final existing = await (_db.select(_db.syncRecords)
          ..where((t) => t.serverId.equals(change.serverId)))
        .getSingleOrNull();

    if (change.operation == SyncOperation.delete) {
      if (existing != null) {
        await (_db.delete(_db.syncRecords)..where((t) => t.localId.equals(existing.localId))).go();
      }
      return;
    }

    if (existing == null) {
      final record = SyncRecord(
        localId: _uuid.v4(),
        serverId: change.serverId,
        eventType: change.eventType,
        operation: SyncOperation.update,
        data: change.data,
        syncStatus: SyncRecordStatus.synced,
        createdAt: change.editedAt,
        editedAt: change.editedAt,
        lastSyncedAt: change.editedAt,
      );
      await _db.into(_db.syncRecords).insert(record.toCompanion());
      return;
    }

    final local = SyncRecord.fromRow(existing);
    if (local.syncStatus == SyncRecordStatus.pending && local.editedAt.isAfter(change.editedAt)) {
      return;
    }

    final merged = local.copyWith(
      data: change.data,
      syncStatus: SyncRecordStatus.synced,
      editedAt: change.editedAt,
      lastSyncedAt: change.editedAt,
      operation: SyncOperation.update,
    );
    await _db.update(_db.syncRecords).replace(merged.toCompanion());
  }
}
