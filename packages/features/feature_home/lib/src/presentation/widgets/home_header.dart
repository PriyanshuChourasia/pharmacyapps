import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import 'address_selector_sheet.dart';

/// Teal pinned header: wordmark, notifications, cart, "Deliver to" row and
/// the pinned search box.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.address,
    required this.cartCount,
    required this.addresses,
    required this.onSelectAddress,
  });

  final Address? address;
  final int cartCount;
  final List<Address> addresses;
  final ValueChanged<String> onSelectAddress;

  static const double _addressRowHeight = 36;
  static const double _searchHeight = 64;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      expandedHeight: kToolbarHeight + _addressRowHeight + _searchHeight,
      titleSpacing: AppSpacing.md,
      title: const Row(
        children: [
          Icon(Icons.medication_rounded, color: Colors.white),
          SizedBox(width: AppSpacing.xs + 2),
          Text(
            'PharmMed',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          color: Colors.white,
          icon: const Icon(Icons.notifications_none),
          onPressed: () => showAppSnackBar(context, 'No new notifications'),
        ),
        CartIconButton(
          count: cartCount,
          color: Colors.white,
          onTap: () => context.go(RoutePaths.cart),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.only(top: topPadding + kToolbarHeight),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: _addressRowHeight,
              child: _DeliverTo(
                address: address,
                onTap: () => showAddressSelectorSheet(
                  context,
                  addresses: addresses,
                  selectedId: address?.id,
                  onSelect: onSelectAddress,
                ),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_searchHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm + 4,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () => context.push(RoutePaths.search),
              child: const SizedBox(
                height: 48,
                child: Row(
                  children: [
                    SizedBox(width: AppSpacing.sm + 4),
                    Icon(Icons.search, color: AppColors.primaryDark),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Search for medicines & health products',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Icon(Icons.mic_none, color: AppColors.textSecondary),
                    SizedBox(width: AppSpacing.sm + 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliverTo extends StatelessWidget {
  const _DeliverTo({required this.address, required this.onTap});

  final Address? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = address;
    final firstName = a?.fullName.split(' ').first ?? 'you';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: 'Deliver to ',
                  children: [
                    TextSpan(
                      text: firstName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (a != null) TextSpan(text: ' — ${a.city} ${a.pincode}'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
