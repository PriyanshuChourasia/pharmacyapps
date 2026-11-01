import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/orders_cubit.dart';
import '../widgets/order_status_timeline.dart';

/// One order: status timeline, items, address, slot, payment and bill.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id =
        GoRouterState.of(context).pathParameters[RoutePaths.orderIdParam] ?? '';
    return FutureBuilder<Result<Order?>>(
      future: GetIt.instance<OrdersRepository>().getOrder(id),
      builder: (context, snapshot) {
        final order = snapshot.data?.dataOrNull;
        return Scaffold(
          appBar: AppBar(title: Text('Order #$id')),
          body: !snapshot.hasData
              ? const LoadingView()
              : order == null
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'Order not found',
                  actionLabel: 'Back to orders',
                  onAction: () => context.go(RoutePaths.orders),
                )
              : _DetailBody(order: order),
          bottomNavigationBar: order == null ? null : _Actions(order: order),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _Section(
          title: 'Order status',
          child: OrderStatusTimeline(
            status: order.status,
            placedAt: order.createdAt,
          ),
        ),
        _Section(
          title: 'Items',
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      ProductImage(
                        assetPath: item.product.imageAsset,
                        icon: Icons.medication_outlined,
                        letter: item.product.name,
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.qty} × ${Money.format(item.product.price)}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Money.format(item.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _Section(
          title: 'Delivery address',
          child: Text(
            '${order.address.fullName} · ${order.address.phone}\n'
            '${order.address.summary}',
          ),
        ),
        _Section(title: 'Delivery slot', child: Text(order.slot)),
        _Section(
          title: 'Payment',
          child: Row(
            children: [
              Icon(
                order.isPrepaid ? Icons.qr_code_2 : Icons.payments_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(order.paymentMethod.label)),
              Chip(
                label: Text(order.isPrepaid ? 'Paid' : 'Pay on delivery'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        _Section(
          title: 'Bill details',
          child: BillDetails(
            breakdown: order.breakdown,
            totalLabel: order.isPrepaid ? 'Total paid' : 'To pay',
          ),
        ),
        Text(
          'Placed on ${formatDateTime(order.createdAt)}',
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.sectionTitle),
            const SizedBox(height: AppSpacing.sm + 4),
            child,
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => showAppSnackBar(
                  context,
                  'Support: help@pharmmed.demo · 1800-000-0000',
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Need help?'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Reorder',
                icon: Icons.replay,
                onPressed: () async {
                  final message = await reorderInto(
                    GetIt.instance<CartRepository>(),
                    order,
                  );
                  if (context.mounted) showAppSnackBar(context, message);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
