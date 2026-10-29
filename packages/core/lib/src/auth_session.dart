import 'result.dart';

/// Session state for sign-in. The demo implementation lives in the
/// `authentication` package and is registered by `feature_auth`'s module;
/// checkout and profile depend only on this interface.
abstract interface class AuthSession {
  /// Whether a user is currently signed in.
  bool get isLoggedIn;

  /// Display name of the signed-in user, or `null` when signed out.
  String? get userName;

  /// Emits every time the sign-in state changes.
  Stream<bool> get authChanges;

  /// Demo sign-in: accepts any non-empty identifier and password.
  Future<Result<SessionInfo>> login({
    required String identifier,
    required String password,
  });

  /// Ends the current session (no-op when signed out).
  void logout();
}

/// Minimal session info produced by a successful login.
class SessionInfo {
  const SessionInfo({required this.userName, required this.identifier});

  /// Display name derived from the identifier.
  final String userName;

  /// The phone/email the user signed in with.
  final String identifier;
}
