import 'dart:async';

import 'package:sync_engine/src/db/sync_database.dart';
import 'package:sync_engine/src/models/sync_record.dart';
import 'package:sync_engine/src/models/sync_state.dart';
import 'package:sync_engine/src/store/local_store.dart';
import 'package:sync_engine/src/transport/sync_transport.dart';
import 'package:sync_engine/src/worker/sync_worker.dart';

class SyncEngine {
  SyncEngine._({
    required SyncDatabase database,
    required LocalStore store,
    required SyncWorker worker,
  })  : _database = database,
        _store = store,
        _worker = worker;

  final SyncDatabase _database;
  final LocalStore _store;
  final SyncWorker _worker;
  final _stateController = StreamController<SyncStateUpdate>.broadcast();

  Stream<SyncStateUpdate> get state => _stateController.stream;

  static Future<SyncEngine> open({
    required SyncTransport transport,
    String databaseName = 'sync_engine',
  }) async {
    final database = SyncDatabase.open(name: databaseName);
    final store = LocalStore(database);
    return SyncEngine._(
      database: database,
      store: store,
      worker: SyncWorker(store: store, transport: transport),
    );
  }

  static SyncEngine memory({required SyncTransport transport}) {
    final database = SyncDatabase.memory();
    final store = LocalStore(database);
    return SyncEngine._(
      database: database,
      store: store,
      worker: SyncWorker(store: store, transport: transport),
    );
  }

  Stream<List<SyncRecord>> watch({String? eventType}) => _store.watch(eventType: eventType);

  Future<SyncRecord> create({
    required String eventType,
    required Map<String, dynamic> data,
    String? localId,
  }) {
    return _store.create(eventType: eventType, data: data, localId: localId);
  }

  Future<SyncRecord> update({
    required String localId,
    required Map<String, dynamic> data,
  }) {
    return _store.update(localId: localId, data: data);
  }

  Future<SyncRecord> delete({required String localId}) {
    return _store.markDeleted(localId);
  }

  Future<void> syncNow({List<String>? pullEventTypes}) async {
    _emit(const SyncStateUpdate(state: SyncState.syncing));

    try {
      await _worker.pushPending();

      for (final eventType in pullEventTypes ?? const <String>[]) {
        await _worker.pull(eventType);
      }

      _emit(const SyncStateUpdate(state: SyncState.idle));
    } catch (error) {
      _emit(SyncStateUpdate(state: SyncState.error, message: error.toString()));
      rethrow;
    }
  }

  Future<void> pull(String eventType) => _worker.pull(eventType);

  Future<void> close() async {
    await _stateController.close();
    await _database.close();
  }

  void _emit(SyncStateUpdate update) {
    if (!_stateController.isClosed) {
      _stateController.add(update);
    }
  }
}
