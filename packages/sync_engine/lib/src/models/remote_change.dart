import 'package:sync_engine/src/models/sync_operation.dart';

class RemoteChange {
  const RemoteChange({
    required this.serverId,
    required this.eventType,
    required this.operation,
    required this.data,
    required this.editedAt,
  });

  final String serverId;
  final String eventType;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime editedAt;
}
