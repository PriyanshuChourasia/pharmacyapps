import 'package:feature_home/feature_home.dart';

/// Bundled asset paths the app hands to features (features never hard-code
/// the app's asset paths).
abstract final class AppAssets {
  static const String emptyCart = 'assets/images/illustrations/empty_cart.jpg';

  static const List<HomeBanner> homeBanners = [
    HomeBanner(
      imageAsset: 'assets/images/banners/pharmacy_shelf.jpg',
      title: 'Flat 20% off on medicines',
      subtitle: 'Use code PHARMA10',
      categoryId: 'pain_relief',
      categoryName: 'Pain Relief',
    ),
    HomeBanner(
      imageAsset: 'assets/images/banners/family_health.jpg',
      title: 'Free delivery above ₹499',
      subtitle: 'On all orders',
      categoryId: 'baby_care',
      categoryName: 'Baby Care',
    ),
    HomeBanner(
      imageAsset: 'assets/images/banners/pills_capsules.jpg',
      title: 'Vitamins & supplements',
      subtitle: 'Boost your immunity',
      categoryId: 'vitamins',
      categoryName: 'Vitamins & Supplements',
    ),
  ];
}
