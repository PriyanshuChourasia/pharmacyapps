import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Four shortcut cards under the header.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.onOffers});

  final VoidCallback onOffers;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.upload_file_outlined,
        'Order with prescription',
        () => showAppSnackBar(
          context,
          'Add your medicines, then upload the prescription at checkout',
        ),
      ),
      (Icons.replay, 'Reorder', () => context.go(RoutePaths.orders)),
      (Icons.local_offer_outlined, 'Offers', onOffers),
      (
        Icons.biotech_outlined,
        'Lab tests',
        () => showAppSnackBar(context, 'Lab tests are coming soon'),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          for (final (icon, label, onTap) in actions)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    child: SizedBox(
                      height: 92,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(icon, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: AppSpacing.xs + 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
