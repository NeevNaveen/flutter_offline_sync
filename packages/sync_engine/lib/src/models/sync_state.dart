enum SyncState { idle, syncing, error }

class SyncStateUpdate {
  const SyncStateUpdate({
    required this.state,
    this.message,
  });

  final SyncState state;
  final String? message;
}
