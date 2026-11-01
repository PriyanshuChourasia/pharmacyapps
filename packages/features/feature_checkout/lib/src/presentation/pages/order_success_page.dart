import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../widgets/success_check_animation.dart';

/// Shown after an order is placed. Back is disabled; the user continues to
/// the order or to Home.
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).uri.queryParameters['id'] ?? '';
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<Result<Order?>>(
            future: GetIt.instance<OrdersRepository>().getOrder(id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingView();
              final order = snapshot.data!.dataOrNull;
              return _SuccessBody(orderId: id, order: order);
            },
          ),
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.orderId, required this.order});

  final String orderId;
  final Order? order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          const SuccessCheckAnimation(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Order placed successfully!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Order ID: $orderId',
                  style: AppTypography.bodySecondary,
                ),
              ),
              IconButton(
                tooltip: 'Copy order id',
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: orderId));
                  if (context.mounted) {
                    showAppSnackBar(context, 'Order ID copied');
                  }
                },
              ),
            ],
          ),
          if (o != null) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _InfoLine(
                      Icons.local_shipping_outlined,
                      'Arriving: ${o.slot}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoLine(
                      o.isPrepaid
                          ? Icons.check_circle_outline
                          : Icons.payments_outlined,
                      o.isPrepaid
                          ? 'Paid ${Money.format(o.breakdown.payable)} via UPI'
                          : 'Pay ${Money.format(o.breakdown.payable)} on delivery',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoLine(Icons.location_on_outlined, o.address.summary),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          AppButton(
            label: 'View order',
            onPressed: () => context.go(RoutePaths.orderDetail(orderId)),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Continue shopping'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    );
  }
}
