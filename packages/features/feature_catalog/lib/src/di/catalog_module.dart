import 'package:get_it/get_it.dart';
import 'package:shared_models/shared_models.dart';

import '../data/datasources/demo_catalog_data_source.dart';
import '../data/repositories/demo_catalog_repository.dart';

/// Registers the catalog module: demo datasource + repository.
/// Called from the app's `configureDependencies()`.
void registerCatalogModule(GetIt getIt) {
  getIt
    ..registerLazySingleton<DemoCatalogDataSource>(DemoCatalogDataSource.new)
    ..registerLazySingleton<CatalogRepository>(
      () => DemoCatalogRepository(getIt<DemoCatalogDataSource>()),
    );
}
