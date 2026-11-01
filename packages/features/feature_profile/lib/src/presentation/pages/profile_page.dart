import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/profile_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';

/// Profile tab: guest/sign-in header, account menu and log out.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.appVersion = 'v1.0.0 (demo)'});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(GetIt.instance<AuthSession>()),
      child: _ProfileView(appVersion: appVersion),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.appVersion});

  final String appVersion;

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your cart will stay on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ProfileCubit>().logout();
      showAppSnackBar(context, 'You have been logged out');
    }
  }

  void _showOffers(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Offers & coupons',
                style: AppTypography.sectionTitle,
              ),
            ),
            for (final c in PricingCalculator.coupons)
              ListTile(
                leading: const Icon(
                  Icons.local_offer,
                  color: AppColors.discount,
                ),
                title: Text(
                  c.code,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${c.title}. ${c.rule}'),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Help & support', style: AppTypography.sectionTitle),
            ),
            ListTile(
              leading: Icon(Icons.call_outlined),
              title: Text('1800-000-0000'),
              subtitle: Text('Toll free · 8 AM to 10 PM (demo)'),
            ),
            ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('help@pharmmed.demo'),
              subtitle: Text('We reply within 24 hours (demo)'),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, SessionInfo?>(
        builder: (context, session) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ProfileHeader(
                session: session,
                onLogin: () => context.push(RoutePaths.login),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ProfileMenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'My orders',
                      onTap: () => context.go(RoutePaths.orders),
                    ),
                    ProfileMenuTile(
                      icon: Icons.location_on_outlined,
                      title: 'Saved addresses',
                      onTap: () => context.push(RoutePaths.savedAddresses),
                    ),
                    ProfileMenuTile(
                      icon: Icons.description_outlined,
                      title: 'My prescriptions',
                      onTap: () => showAppSnackBar(
                        context,
                        'Saved prescriptions are coming soon',
                      ),
                    ),
                    ProfileMenuTile(
                      icon: Icons.local_offer_outlined,
                      title: 'Offers & coupons',
                      onTap: () => _showOffers(context),
                    ),
                    ProfileMenuTile(
                      icon: Icons.support_agent,
                      title: 'Help & support',
                      onTap: () => _showHelp(context),
                    ),
                    ProfileMenuTile(
                      icon: Icons.info_outline,
                      title: 'About PharmMed',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'PharmMed',
                        applicationVersion: appVersion,
                        applicationIcon: const Icon(
                          Icons.medication_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                        children: const [
                          Text(
                            'A demo online pharmacy. All products, prices and '
                            'payments are simulated.',
                          ),
                        ],
                      ),
                    ),
                    if (kDebugMode)
                      ProfileMenuTile(
                        icon: Icons.widgets_outlined,
                        title: 'UI kit',
                        subtitle: 'Debug builds only',
                        onTap: () => context.push(RoutePaths.uiKit),
                      ),
                  ],
                ),
              ),
              if (session != null) ...[
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                appVersion,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          );
        },
      ),
    );
  }
}
