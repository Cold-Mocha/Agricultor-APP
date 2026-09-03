enum SessionStatus { restoring, locked, signedOut, signedIn, offline }

final class SessionState {
  const SessionState({
    required this.status,
    this.ownerId,
    this.message,
    this.biometricEnabled = false,
    this.offline = false,
  });

  const SessionState.restoring() : this(status: SessionStatus.restoring);
  const SessionState.signedOut({String? message})
    : this(status: SessionStatus.signedOut, message: message);
  const SessionState.signedIn(String ownerId)
    : this(status: SessionStatus.signedIn, ownerId: ownerId);
  const SessionState.offline(String ownerId, {bool biometricEnabled = false})
    : this(
        status: SessionStatus.offline,
        ownerId: ownerId,
        biometricEnabled: biometricEnabled,
        offline: true,
      );
  const SessionState.locked(
    String ownerId, {
    bool biometricEnabled = true,
    bool offline = false,
    String? message,
  }) : this(
         status: SessionStatus.locked,
         ownerId: ownerId,
         biometricEnabled: biometricEnabled,
         offline: offline,
         message: message,
       );

  final SessionStatus status;
  final String? ownerId;
  final String? message;
  final bool biometricEnabled;
  final bool offline;

  bool get hasLocalAccess =>
      status == SessionStatus.signedIn || status == SessionStatus.offline;
}
