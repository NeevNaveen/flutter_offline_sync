enum SyncErrorCode { network, conflict, auth, validation }

class SyncTransportException implements Exception {
  SyncTransportException(this.code, [this.message]);

  final SyncErrorCode code;
  final String? message;

  @override
  String toString() => 'SyncTransportException($code${message == null ? '' : ': $message'})';
}
