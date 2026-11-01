import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/orders_cubit.dart';
import '../widgets/order_card.dart';

/// Orders tab: newest first, with reorder.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(
        GetIt.instance<OrdersRepository>(),
        GetIt.instance<CartRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.loading) return const LoadingView();
            if (state.orders.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Your placed orders will appear here',
                actionLabel: 'Start shopping',
                onAction: () => context.go(RoutePaths.home),
              );
            }
            final cubit = context.read<OrdersCubit>();
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return StaggeredFadeIn(
                  index: index,
                  child: OrderCard(
                    order: order,
                    onTap: () => context.push(RoutePaths.orderDetail(order.id)),
                    onReorder: () async {
                      final message = await cubit.reorder(order);
                      if (context.mounted) showAppSnackBar(context, message);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
