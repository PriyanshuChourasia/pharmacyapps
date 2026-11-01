import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Emits the current [SessionInfo] (`null` = guest) on every auth change.
class ProfileCubit extends Cubit<SessionInfo?> {
  ProfileCubit(this._auth) : super(_auth.currentSession) {
    _sub = _auth.authChanges.listen((_) {
      if (!isClosed) emit(_auth.currentSession);
    });
  }

  final AuthSession _auth;
  late final StreamSubscription<bool> _sub;

  void logout() => _auth.logout();

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
