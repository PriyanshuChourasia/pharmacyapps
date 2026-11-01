import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

import '../../domain/delivery_slot.dart';

/// State of the checkout page.
class CheckoutState extends Equatable {
  const CheckoutState({
    this.items = const [],
    this.breakdown = const PriceBreakdown.empty(),
    this.addresses = const [],
    this.selectedAddressId,
    this.slotDay = SlotDay.tomorrow,
    this.slotTime = SlotTime.morning,
    this.paymentMethod = PaymentMethod.cod,
    this.prescriptionAttached = false,
    this.placing = false,
  });

  final List<CartItem> items;
  final PriceBreakdown breakdown;
  final List<Address> addresses;
  final String? selectedAddressId;
  final SlotDay slotDay;
  final SlotTime slotTime;
  final PaymentMethod paymentMethod;
  final bool prescriptionAttached;

  /// True while the order is being placed (and after success, until the
  /// page navigates away).
  final bool placing;

  int get rxCount => items.where((i) => i.product.requiresPrescription).length;
  bool get hasRx => rxCount > 0;
  DeliverySlot get slot => DeliverySlot(slotDay, slotTime);

  CheckoutState copyWith({
    List<CartItem>? items,
    PriceBreakdown? breakdown,
    List<Address>? addresses,
    String? selectedAddressId,
    SlotDay? slotDay,
    SlotTime? slotTime,
    PaymentMethod? paymentMethod,
    bool? prescriptionAttached,
    bool? placing,
  }) => CheckoutState(
    items: items ?? this.items,
    breakdown: breakdown ?? this.breakdown,
    addresses: addresses ?? this.addresses,
    selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    slotDay: slotDay ?? this.slotDay,
    slotTime: slotTime ?? this.slotTime,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    prescriptionAttached: prescriptionAttached ?? this.prescriptionAttached,
    placing: placing ?? this.placing,
  );

  @override
  List<Object?> get props => [
    items,
    breakdown,
    addresses,
    selectedAddressId,
    slotDay,
    slotTime,
    paymentMethod,
    prescriptionAttached,
    placing,
  ];
}
