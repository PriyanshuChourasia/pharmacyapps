import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../../domain/place_order_use_case.dart';
import '../state/checkout_cubit.dart';
import '../state/checkout_state.dart';
import '../widgets/address_card.dart';
import '../widgets/checkout_section_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_options.dart';
import '../widgets/place_order_bar.dart';
import '../widgets/prescription_section.dart';
import '../widgets/slot_picker.dart';

/// Single-page checkout: address, slot, prescription, payment and summary.
/// Guests are asked to log in only when they tap "Place order".
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    return BlocProvider(
      create: (_) => CheckoutCubit(
        cart: getIt<CartRepository>(),
        addresses: getIt<AddressRepository>(),
        placeOrderUseCase: getIt<PlaceOrderUseCase>(),
      ),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  final _prescriptionKey = GlobalKey();

  void _showError(String message, String? code) {
    showAppSnackBar(context, message, error: true);
    if (code == 'prescription_required') {
      final target = _prescriptionKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 350),
          alignment: 0.1,
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    final cubit = context.read<CheckoutCubit>();
    final invalid = cubit.validate();
    if (invalid != null) {
      _showError(invalid.message, invalid.code);
      return;
    }

    final auth = GetIt.instance<AuthSession>();
    if (!auth.isLoggedIn) {
      final ok = await context.push<bool>(RoutePaths.login);
      if (!mounted) return;
      if (ok != true || !auth.isLoggedIn) {
        showAppSnackBar(context, 'Please log in to place your order');
        return;
      }
    }

    final result = await cubit.placeOrder();
    if (!mounted) return;
    result.when(
      onSuccess: (order) => context.go(RoutePaths.orderSuccess(order.id)),
      onFailure: _showError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final cubit = context.read<CheckoutCubit>();
        if (state.items.isEmpty && !state.placing) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add medicines before checking out.',
              actionLabel: 'Browse medicines',
              onAction: () => context.go(RoutePaths.home),
            ),
          );
        }
        var step = 1;
        return Scaffold(
          appBar: AppBar(title: const Text('Checkout')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              CheckoutSectionCard(
                step: step++,
                title: 'Delivery address',
                child: AddressList(
                  addresses: state.addresses,
                  selectedId: state.selectedAddressId,
                  onSelect: cubit.selectAddress,
                  onAddNew: () => context.push(RoutePaths.addAddress),
                ),
              ),
              CheckoutSectionCard(
                step: step++,
                title: 'Delivery slot',
                child: SlotPicker(
                  day: state.slotDay,
                  time: state.slotTime,
                  onDay: cubit.selectDay,
                  onTime: cubit.selectTime,
                ),
              ),
              if (state.hasRx)
                CheckoutSectionCard(
                  key: _prescriptionKey,
                  step: step++,
                  title: 'Prescription',
                  child: PrescriptionSection(
                    rxCount: state.rxCount,
                    attached: state.prescriptionAttached,
                    onAttach: cubit.attachPrescription,
                    onRemove: cubit.removePrescription,
                  ),
                ),
              CheckoutSectionCard(
                step: step++,
                title: 'Payment method',
                child: PaymentOptions(
                  selected: state.paymentMethod,
                  onChanged: cubit.selectPayment,
                ),
              ),
              CheckoutSectionCard(
                step: step++,
                title: 'Order summary',
                child: OrderSummaryCard(
                  items: state.items,
                  breakdown: state.breakdown,
                ),
              ),
            ],
          ),
          bottomNavigationBar: PlaceOrderBar(
            payable: state.breakdown.payable,
            placing: state.placing,
            isUpi: state.paymentMethod == PaymentMethod.upi,
            onPlaceOrder: _placeOrder,
          ),
        );
      },
    );
  }
}
