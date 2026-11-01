import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Teal gradient card: guest prompt or the signed-in user.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.session,
    required this.onLogin,
  });

  final SessionInfo? session;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: s == null ? _guest() : _signedIn(context, s),
    );
  }

  Widget _guest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Guest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Log in to see your orders and save addresses',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: onLogin,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size.fromHeight(44),
          ),
          child: const Text('Log in / Sign up'),
        ),
      ],
    );
  }

  Widget _signedIn(BuildContext context, SessionInfo s) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Text(
            s.userName.isEmpty ? '?' : s.userName[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(s.identifier, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Edit profile',
          color: Colors.white,
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              showAppSnackBar(context, 'Profile editing is coming soon'),
        ),
      ],
    );
  }
}
