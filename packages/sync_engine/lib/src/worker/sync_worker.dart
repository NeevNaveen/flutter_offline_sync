import 'package:sync_engine/src/models/push_result.dart';
import 'package:sync_engine/src/models/sync_record.dart';
import 'package:sync_engine/src/store/local_store.dart';
import 'package:sync_engine/src/transport/sync_transport.dart';
import 'package:sync_engine/src/transport/sync_transport_exception.dart';

class SyncWorker {
  SyncWorker({
    required LocalStore store,
    required SyncTransport transport,
    this.maxRetries = 5,
  })  : _store = store,
        _transport = transport;

  final LocalStore _store;
  final SyncTransport _transport;
  final int maxRetries;

  Future<void> pushPending() async {
    final pending = await _store.pendingRecords();

    for (final record in pending) {
      if (record.retryCount >= maxRetries) {
        await _store.markFailed(record);
        continue;
      }

      try {
        final PushResult result = await _transport.push(record);
        await _store.applyPushSuccess(
          record,
          result.syncedAt,
          serverId: result.serverId,
          data: result.data,
        );
      } on SyncTransportException catch (error) {
        await _handleTransportError(record, error);
      }
    }
  }

  Future<void> pull(String eventType) async {
    final since = await _store.lastPullAt(eventType);
    final changes = await _transport.pull(eventType: eventType, since: since);

    for (final change in changes) {
      await _store.applyRemoteChange(change);
    }

    if (changes.isNotEmpty) {
      final latest = changes.map((c) => c.editedAt).reduce((a, b) => a.isAfter(b) ? a : b);
      await _store.setLastPullAt(eventType, latest);
    } else if (since != null) {
      await _store.setLastPullAt(eventType, DateTime.now().toUtc());
    } else {
      await _store.setLastPullAt(eventType, DateTime.now().toUtc());
    }
  }

  Future<void> _handleTransportError(SyncRecord record, SyncTransportException error) async {
    switch (error.code) {
      case SyncErrorCode.network:
        await _store.incrementRetry(record);
      case SyncErrorCode.conflict:
        await _store.markConflict(record);
      case SyncErrorCode.auth:
      case SyncErrorCode.validation:
        await _store.markFailed(record);
    }
  }
}
