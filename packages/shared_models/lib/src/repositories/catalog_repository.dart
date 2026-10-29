import 'package:core/core.dart';

import '../models/category.dart';
import '../models/product.dart';

/// Read-side catalog contract shared by features that show products
/// (home shows categories + popular items, catalog shows everything).
///
/// Implemented by `feature_catalog` with a demo datasource; home depends
/// only on this interface, wired up by the app's DI.
abstract interface class CatalogRepository {
  Future<Result<List<Category>>> getCategories();

  /// All products, optionally filtered by category id.
  Future<Result<List<Product>>> getProducts({String? categoryId});

  /// A single product, or `null` when the id is unknown.
  Future<Result<Product?>> getProduct(String id);

  /// Free-text search over brand name, generic name and salt composition.
  Future<Result<List<Product>>> searchProducts(String query);
}
