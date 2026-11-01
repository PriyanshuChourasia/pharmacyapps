import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'registration_page.dart';

/// Login gate opened from checkout (and Profile). Pops `true` on success.
///
/// Demo: any non-empty phone/email + password signs in.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.session});

  /// Defaults to the [AuthSession] registered in GetIt.
  final AuthSession? session;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  AuthSession get _session => widget.session ?? GetIt.instance<AuthSession>();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await _session.login(
      identifier: _identifier.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.when(
      onSuccess: (session) {
        showAppSnackBar(context, 'Welcome, ${session.userName}!');
        context.pop(true);
      },
      onFailure: (message, _) => setState(() => _error = message),
    );
  }

  Future<void> _openRegistration() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegistrationPage(session: _session)),
    );
    if (ok == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.pop(false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(
                    Icons.medication_rounded,
                    size: 40,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Log in to place your order',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Demo: any phone/email and password works',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _identifier,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.telephoneNumber,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile number or email',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your mobile number or email'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Log in',
                  loading: _submitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _submitting ? null : _openRegistration,
                  child: const Text('New to PharmMed? Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
