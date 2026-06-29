import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sync_engine/src/db/sync_database.dart' show SyncRecordRow, SyncRecordsCompanion;
import 'package:sync_engine/src/models/sync_operation.dart';
import 'package:sync_engine/src/models/sync_record_status.dart';

class SyncRecord {
  const SyncRecord({
    required this.localId,
    required this.eventType,
    required this.operation,
    required this.data,
    required this.syncStatus,
    required this.createdAt,
    required this.editedAt,
    this.serverId,
    this.lastSyncedAt,
    this.retryCount = 0,
  });

  final String localId;
  final String? serverId;
  final String eventType;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final SyncRecordStatus syncStatus;
  final DateTime createdAt;
  final DateTime editedAt;
  final DateTime? lastSyncedAt;
  final int retryCount;

  SyncRecord copyWith({
    String? serverId,
    String? eventType,
    SyncOperation? operation,
    Map<String, dynamic>? data,
    SyncRecordStatus? syncStatus,
    DateTime? createdAt,
    DateTime? editedAt,
    DateTime? lastSyncedAt,
    int? retryCount,
  }) {
    return SyncRecord(
      localId: localId,
      serverId: serverId ?? this.serverId,
      eventType: eventType ?? this.eventType,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  factory SyncRecord.fromRow(SyncRecordRow row) {
    return SyncRecord(
      localId: row.localId,
      serverId: row.serverId,
      eventType: row.eventType,
      operation: SyncOperation.values.byName(row.operation),
      data: jsonDecode(row.data) as Map<String, dynamic>,
      syncStatus: SyncRecordStatus.values.byName(row.syncStatus),
      createdAt: row.createdAt,
      editedAt: row.editedAt,
      lastSyncedAt: row.lastSyncedAt,
      retryCount: row.retryCount,
    );
  }

  SyncRecordsCompanion toCompanion() {
    return SyncRecordsCompanion.insert(
      localId: localId,
      serverId: Value(serverId),
      eventType: eventType,
      operation: operation.name,
      data: jsonEncode(data),
      syncStatus: syncStatus.name,
      createdAt: createdAt,
      editedAt: editedAt,
      lastSyncedAt: Value(lastSyncedAt),
      retryCount: Value(retryCount),
    );
  }
}
