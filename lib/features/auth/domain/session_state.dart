enum SessionStatus { checking, signedOut, signedIn }

final class SessionState {
  const SessionState({required this.status, this.ownerId, this.message});

  const SessionState.checking() : this(status: SessionStatus.checking);
  const SessionState.signedOut({String? message})
    : this(status: SessionStatus.signedOut, message: message);
  const SessionState.signedIn(String ownerId)
    : this(status: SessionStatus.signedIn, ownerId: ownerId);

  final SessionStatus status;
  final String? ownerId;
  final String? message;
}
