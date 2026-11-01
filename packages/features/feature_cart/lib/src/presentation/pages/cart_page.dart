import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/cart_cubit.dart';
import '../state/cart_state.dart';
import '../widgets/bill_details_card.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/coupon_section.dart';
import '../widgets/rx_banner.dart';

/// Cart tab: line items, coupons, bill details and the checkout bar.
class CartPage extends StatelessWidget {
  const CartPage({super.key, this.emptyImageAsset});

  /// Illustration for the empty cart (an app asset path).
  final String? emptyImageAsset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(GetIt.instance<CartRepository>()),
      child: _CartView(emptyImageAsset: emptyImageAsset),
    );
  }
}

class _CartView extends StatefulWidget {
  const _CartView({this.emptyImageAsset});

  final String? emptyImageAsset;

  @override
  State<_CartView> createState() => _CartViewState();
}

class _CartViewState extends State<_CartView> {
  final _billKey = GlobalKey();

  void _scrollToBill() {
    final target = _billKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.1,
    );
  }

  Future<void> _remove(CartItem item) async {
    final cubit = context.read<CartCubit>();
    final removed = await cubit.remove(item.productId);
    if (!mounted || removed == null) return;
    showAppSnackBar(
      context,
      '${removed.product.name} removed',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => cubit.undoRemove(removed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (a, b) => b.limitMessage != null,
      listener: (context, state) {
        showAppSnackBar(context, state.limitMessage);
        context.read<CartCubit>().clearLimitMessage();
      },
      builder: (context, state) {
        final count = state.unitCount;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.isEmpty
                  ? 'My Cart'
                  : 'My Cart ($count item${count == 1 ? '' : 's'})',
            ),
          ),
          body: state.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  imageAsset: widget.emptyImageAsset,
                  title: 'Your cart is empty',
                  message: 'Add medicines to get started',
                  actionLabel: 'Browse medicines',
                  onAction: () => context.go(RoutePaths.categories),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (state.rxCount > 0) RxBanner(count: state.rxCount),
                    for (final item in state.items)
                      CartLineTile(
                        key: ValueKey(item.productId),
                        item: item,
                        onQtyChanged: (qty) => context.read<CartCubit>().setQty(
                          item.productId,
                          qty,
                        ),
                        onRemove: () => _remove(item),
                        onTap: () => context.push(
                          RoutePaths.productDetail(item.productId),
                        ),
                      ),
                    if (state.totalSavings > 0)
                      _SavingsStrip(state.totalSavings),
                    const SizedBox(height: AppSpacing.md),
                    CouponSection(state: state),
                    const SizedBox(height: AppSpacing.md),
                    BillDetailsCard(
                      key: _billKey,
                      breakdown: state.breakdown,
                      amountForFreeDelivery: context
                          .read<CartCubit>()
                          .amountForFreeDelivery,
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.go(RoutePaths.home),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Continue shopping'),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: state.isEmpty
              ? null
              : CartBottomBar(
                  payable: state.breakdown.payable,
                  onViewBill: _scrollToBill,
                  onCheckout: () => context.push(RoutePaths.checkout),
                ),
        );
      },
    );
  }
}

class _SavingsStrip extends StatelessWidget {
  const _SavingsStrip(this.savings);

  final int savings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.savings_outlined, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "You're saving ",
                children: [
                  TextSpan(
                    text: Money.format(savings),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' on this order'),
                ],
              ),
              style: const TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
