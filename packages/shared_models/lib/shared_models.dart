/// Public API for shared_models: entities and cross-feature contracts
/// shared by the apps (products, cart, orders) and the abstract repositories
/// that connect features without importing each other.
library;

export 'src/models/address.dart';
export 'src/models/cart_item.dart';
export 'src/models/category.dart';
export 'src/models/money.dart';
export 'src/models/order.dart';
export 'src/models/price_breakdown.dart';
export 'src/models/product.dart';
export 'src/repositories/cart_repository.dart';
export 'src/repositories/catalog_repository.dart';
