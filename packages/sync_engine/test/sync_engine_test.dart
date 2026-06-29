import 'package:flutter_test/flutter_test.dart';
import 'package:sync_engine/sync_engine.dart';

void main() {
  group('SyncEngine', () {
    late SyncEngine engine;
    late FakeTransport transport;

    setUp(() {
      transport = FakeTransport();
      engine = SyncEngine.memory(transport: transport);
    });

    tearDown(() => engine.close());

    test('create stores pending record locally', () async {
      final record = await engine.create(
        eventType: 'restaurantInspection',
        data: {'siteName': 'Cafe Roma'},
      );

      expect(record.syncStatus, SyncRecordStatus.pending);
      expect(record.eventType, 'restaurantInspection');
      expect(record.operation, SyncOperation.create);
    });

    test('syncNow pushes pending record through transport', () async {
      await engine.create(
        eventType: 'restaurantInspection',
        data: {'siteName': 'Cafe Roma'},
      );

      await engine.syncNow();

      expect(transport.pushCount, 1);

      final records = await engine.watch().first;
      expect(records, hasLength(1));
      expect(records.first.syncStatus, SyncRecordStatus.synced);
      expect(records.first.serverId, 'server-1');
    });

    test('update after sync marks record pending again', () async {
      final created = await engine.create(
        eventType: 'constructionInspection',
        data: {'siteName': 'Tower A'},
      );

      await engine.syncNow();
      await engine.update(localId: created.localId, data: {'siteName': 'Tower B'});
      await engine.syncNow();

      expect(transport.pushCount, 2);

      final records = await engine.watch().first;
      expect(records.first.data['siteName'], 'Tower B');
      expect(records.first.syncStatus, SyncRecordStatus.synced);
    });

    test('network error keeps record pending', () async {
      transport.failNextWith = SyncTransportException(SyncErrorCode.network);

      await engine.create(
        eventType: 'profileEdit',
        data: {'name': 'Alex'},
      );

      await engine.syncNow();

      final records = await engine.watch().first;
      expect(records.first.syncStatus, SyncRecordStatus.pending);
      expect(records.first.retryCount, 1);
    });
  });
}

class FakeTransport implements SyncTransport {
  int pushCount = 0;
  SyncTransportException? failNextWith;

  @override
  Future<PushResult> push(SyncRecord record) async {
    pushCount++;
    if (failNextWith != null) {
      final error = failNextWith!;
      failNextWith = null;
      throw error;
    }

    return PushResult(
      serverId: record.serverId ?? 'server-1',
      syncedAt: DateTime.now().toUtc(),
      data: record.data,
    );
  }

  @override
  Future<List<RemoteChange>> pull({
    required String eventType,
    DateTime? since,
  }) async {
    return const [];
  }
}
