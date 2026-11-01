import 'dart:async';

import 'package:core/core.dart';

/// Demo [AuthSession]: any non-empty identifier + password signs in after a
/// short delay. The session lives in memory for the app run.
class DemoAuthSession implements AuthSession {
  final StreamController<bool> _changes = StreamController<bool>.broadcast();
  SessionInfo? _session;

  @override
  bool get isLoggedIn => _session != null;

  @override
  String? get userName => _session?.userName;

  @override
  SessionInfo? get currentSession => _session;

  @override
  Stream<bool> get authChanges => _changes.stream;

  @override
  Future<Result<SessionInfo>> login({
    required String identifier,
    required String password,
    String? name,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final id = identifier.trim();
    if (id.isEmpty || password.isEmpty) {
      return const Failure(
        'Enter your phone/email and password',
        code: 'invalid_credentials',
      );
    }
    final session = SessionInfo(
      userName: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : _nameFrom(id),
      identifier: id,
    );
    _session = session;
    _changes.add(true);
    return Success(session);
  }

  @override
  void logout() {
    if (_session == null) return;
    _session = null;
    _changes.add(false);
  }

  /// "rahul.sharma@mail.com" → "Rahul.sharma"; phone numbers → "Customer".
  static String _nameFrom(String identifier) {
    if (!identifier.contains('@')) return 'Customer';
    final local = identifier.split('@').first;
    if (local.isEmpty) return 'Customer';
    return local[0].toUpperCase() + local.substring(1);
  }
}
