import 'package:sync_engine/src/models/push_result.dart';
import 'package:sync_engine/src/models/remote_change.dart';
import 'package:sync_engine/src/models/sync_record.dart';

abstract class SyncTransport {
  Future<PushResult> push(SyncRecord record);

  Future<List<RemoteChange>> pull({
    required String eventType,
    DateTime? since,
  });
}
