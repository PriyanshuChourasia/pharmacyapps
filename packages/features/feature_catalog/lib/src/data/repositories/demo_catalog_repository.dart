import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';

import '../datasources/demo_catalog_data_source.dart';

/// [CatalogRepository] backed by [DemoCatalogDataSource].
///
/// Swapping in a real API later means a new datasource class and a DI change
/// — no feature code moves.
class DemoCatalogRepository implements CatalogRepository {
  DemoCatalogRepository(this._source);

  final DemoCatalogDataSource _source;

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      return Success(await _source.fetchCategories());
    } catch (e) {
      return Failure('Could not load categories: $e');
    }
  }

  @override
  Future<Result<List<Product>>> getProducts({String? categoryId}) async {
    try {
      return Success(await _source.fetchProducts(categoryId: categoryId));
    } catch (e) {
      return Failure('Could not load products: $e');
    }
  }

  @override
  Future<Result<Product?>> getProduct(String id) async {
    try {
      return Success(await _source.fetchProduct(id));
    } catch (e) {
      return Failure('Could not load the product: $e');
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      return Success(await _source.search(query));
    } catch (e) {
      return Failure('Search failed: $e');
    }
  }
}
