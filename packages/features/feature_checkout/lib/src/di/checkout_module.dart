import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_models/shared_models.dart';

import '../data/demo_payment_gateway.dart';
import '../data/in_memory_address_repository.dart';
import '../data/in_memory_orders_repository.dart';
import '../domain/place_order_use_case.dart';

/// Registers the demo payment gateway, the shared orders and address
/// repositories, and the place-order use case. Needs a [CartRepository].
void registerCheckoutModule(GetIt getIt) {
  getIt
    ..registerLazySingleton<PaymentGateway>(DemoPaymentGateway.new)
    ..registerLazySingleton<OrdersRepository>(InMemoryOrdersRepository.new)
    ..registerLazySingleton<AddressRepository>(InMemoryAddressRepository.new)
    ..registerFactory<PlaceOrderUseCase>(
      () => PlaceOrderUseCase(
        cart: getIt<CartRepository>(),
        orders: getIt<OrdersRepository>(),
        addresses: getIt<AddressRepository>(),
        payment: getIt<PaymentGateway>(),
      ),
    );
}
