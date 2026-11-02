import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:database/database.dart';
import 'package:feature_cart/feature_cart.dart';
import 'package:feature_catalog/feature_catalog.dart';
import 'package:feature_checkout/feature_checkout.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dawaidukaan/app/services/location_permission_service.dart';

/// The app's composition root.
/// Each feature package exposes a `registerXModule(GetIt)` function; every
/// module is registered here, so swapping an implementation (demo data →
/// real API) only touches this file and the module that owns it.
final GetIt getIt = GetIt.instance;

/// Registers all dependencies. Called from `main()` before `runApp`.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<KeyValueStore>(SharedPrefsKeyValueStore(prefs))
    ..registerLazySingleton<AuthSession>(DemoAuthSession.new)
    ..registerLazySingleton<LocationPermissionService>(LocationPermissionService.new);

  registerCatalogModule(getIt);
  await registerCartModule(getIt);
  // Payment gateway + the shared orders and address repositories.
  registerCheckoutModule(getIt);
}
