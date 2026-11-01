import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_models/shared_models.dart';

import '../data/persisted_cart_repository.dart';

/// Registers the persisted cart. Requires a [KeyValueStore] in [getIt] and
/// restores the saved cart before returning.
Future<void> registerCartModule(GetIt getIt) async {
  final repository = PersistedCartRepository(getIt<KeyValueStore>());
  await repository.load();
  getIt.registerSingleton<CartRepository>(repository);
}
