/// A promo banner on Home. The app supplies these so asset paths stay in
/// the app.
class HomeBanner {
  const HomeBanner({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.ctaLabel = 'Shop now',
    this.categoryId,
    this.categoryName,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
  final String ctaLabel;

  /// Category opened by the CTA; `null` opens the Categories tab.
  final String? categoryId;
  final String? categoryName;
}
