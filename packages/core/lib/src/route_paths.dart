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

  /// Catalog routes. These are top-level (pushed over the shell) so they can
  /// be opened from any tab and "back" returns to where the user came from.
  static const String search = '/search';
  static const String searchQueryParam = 'q';
  static const String categoryProductsBase = '/category';
  static const String categoryIdParam = 'categoryId';
  static const String productDetailBase = '/product';
  static const String productIdParam = 'id';

  /// Order detail (inside the Orders branch).
  static const String orderDetailBase = '/orders';
  static const String orderIdParam = 'id';

  /// Saved addresses (inside the Profile branch).
  static const String savedAddresses = '/profile/addresses';

  /// Top-level routes pushed over the shell.
  static const String splash = '/splash';
  static const String login = '/login';
  static const String checkout = '/checkout';
  static const String addAddress = '/address/new';
  static const String checkoutSuccess = '/order-success';
  static const String uiKit = '/ui-kit';
  static const String locationSetup = '/location-setup';

  /// Path of a product detail page for [id].
  static String productDetail(String id) => '$productDetailBase/$id';

  /// Path of a category's product list.
  static String categoryProducts(String id) => '$categoryProductsBase/$id';

  /// Search pre-filled with [query].
  static String searchFor(String query) =>
      '$search?$searchQueryParam=${Uri.encodeQueryComponent(query)}';

  /// Path of an order detail page for [id].
  static String orderDetail(String id) => '$orderDetailBase/$id';

  /// Order success page for order [id].
  static String orderSuccess(String id) => '$checkoutSuccess?id=$id';
}
