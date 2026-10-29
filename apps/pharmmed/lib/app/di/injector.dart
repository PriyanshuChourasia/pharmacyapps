import 'package:get_it/get_it.dart';
import 'package:feature_catalog/feature_catalog.dart';

/// The app's composition root.
/// Each feature package exposes a `registerXModule(GetIt)` function; every
/// module is registered here, so swapping an implementation (demo data →
/// real API) only touches this file and the module that owns it.
final GetIt getIt = GetIt.instance;

/// Registers all feature modules. Called from `main()` before `runApp`.
void configureDependencies() {
  // Feature modules are registered as their phases land:
  registerCatalogModule(getIt);   // Phase 3
  // registerAuthModule(getIt);      // Phase 6
  // registerCartModule(getIt);      // Phase 4
  // registerCheckoutModule(getIt);  // Phase 6
  // registerOrdersModule(getIt);    // Phase 7
}