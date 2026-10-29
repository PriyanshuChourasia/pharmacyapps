import 'package:flutter/material.dart';

import 'login_page.dart';
import 'registration_page.dart';

/// Entry widget that toggles between [LoginPage] and [RegistrationPage].
///
/// This is a placeholder shell: it holds only the local UI state needed to
/// switch between the two screens. Real routing and auth state come later.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _showLogin
          ? LoginPage(
              key: const ValueKey('login'),
              onRegisterPressed: () => setState(() => _showLogin = false),
            )
          : RegistrationPage(
              key: const ValueKey('registration'),
              onLoginPressed: () => setState(() => _showLogin = true),
            ),
    );
  }
}
