/// Central constants for every navigable route in the app.
///
/// Features navigate by these path strings instead of importing other
/// feature packages, which keeps features decoupled.
abstract final class RoutePaths {
  /// Bottom-nav shell tabs.
  static const String home = '/';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  /// Catalog routes (inside the Categories branch).
  static const String search = '/categories/search';
  static const String productDetailBase = '/categories/product';
  static const String productIdParam = 'id';

  /// Order detail (inside the Orders branch).
  static const String orderDetailBase = '/orders';
  static const String orderIdParam = 'id';

  /// Top-level routes pushed over the shell.
  static const String login = '/login';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout/success';
  static const String uiKit = '/ui-kit';

  /// Path of a product detail page for [id].
  static String productDetail(String id) => '$productDetailBase/$id';

  /// Path of an order detail page for [id].
  static String orderDetail(String id) => '$orderDetailBase/$id';
}
