import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import '../state/cart_cubit.dart';
import '../state/cart_state.dart';

/// Coupon entry with suggestion chips, the applied tile and errors.
class CouponSection extends StatefulWidget {
  const CouponSection({super.key, required this.state});

  final CartState state;

  @override
  State<CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<CouponSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(String code) {
    FocusScope.of(context).unfocus();
    _controller.text = code;
    context.read<CartCubit>().applyCoupon(code);
  }

  @override
  Widget build(BuildContext context) {
    final applied = widget.state.appliedCoupon;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_offer_outlined, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Text('Apply coupon', style: AppTypography.sectionTitle),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            if (applied != null)
              _AppliedTile(
                code: applied,
                saved: widget.state.breakdown.couponDiscount,
                onRemove: () {
                  _controller.clear();
                  context.read<CartCubit>().removeCoupon();
                },
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _apply,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        isDense: true,
                        errorText: widget.state.couponError,
                        errorMaxLines: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => _apply(_controller.text),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final coupon in PricingCalculator.coupons)
                    ActionChip(
                      avatar: const Icon(Icons.sell_outlined, size: 16),
                      label: Text('${coupon.code} · ${coupon.title}'),
                      onPressed: () => _apply(coupon.code),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppliedTile extends StatelessWidget {
  const _AppliedTile({
    required this.code,
    required this.saved,
    required this.onRemove,
  });

  final String code;
  final int saved;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$code applied — you saved ${Money.format(saved)}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onRemove, child: const Text('Remove')),
        ],
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return tile;
    return TweenAnimationBuilder<double>(
      key: ValueKey(code),
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: tile,
    );
  }
}
