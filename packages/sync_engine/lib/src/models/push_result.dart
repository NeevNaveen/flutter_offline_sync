class PushResult {
  const PushResult({
    required this.serverId,
    required this.syncedAt,
    this.data,
  });

  final String serverId;
  final DateTime syncedAt;
  final Map<String, dynamic>? data;
}
