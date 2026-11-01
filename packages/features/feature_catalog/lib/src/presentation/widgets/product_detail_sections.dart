import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Expandable Description / Salt / Uses / Side effects / Storage sections.
class ProductInfoSections extends StatelessWidget {
  const ProductInfoSections({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _tile(
            'Description',
            Icons.info_outline,
            Text(product.description),
            initiallyExpanded: true,
          ),
          _tile(
            'Salt composition',
            Icons.science_outlined,
            Text('${product.salt}\nGeneric: ${product.genericName}'),
          ),
          _tile('Uses', Icons.healing_outlined, _Bullets(product.uses)),
          _tile(
            'Side effects',
            Icons.warning_amber_outlined,
            _Bullets(product.sideEffects),
          ),
          _tile('Storage', Icons.inventory_2_outlined, Text(product.storage)),
        ],
      ),
    );
  }

  Widget _tile(
    String title,
    IconData icon,
    Widget body, {
    bool initiallyExpanded = false,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      initiallyExpanded: initiallyExpanded,
      shape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [body],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7),
                  child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(line)),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Delivery by tomorrow · Free delivery above ₹499" strip.
class DeliveryInfoRow extends StatelessWidget {
  const DeliveryInfoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const Row(
        children: [
          Expanded(
            child: _InfoItem(
              Icons.local_shipping_outlined,
              'Delivery by tomorrow',
            ),
          ),
          Expanded(
            child: _InfoItem(Icons.currency_rupee, 'Free delivery above ₹499'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Horizontal row of same-salt alternatives.
class SubstitutesRow extends StatelessWidget {
  const SubstitutesRow({
    super.key,
    required this.substitutes,
    required this.onTap,
  });

  final List<Product> substitutes;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Substitutes (same composition)'),
        SizedBox(
          height: 76,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: substitutes.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final sub = substitutes[index];
              return SizedBox(
                width: 230,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onTap(sub),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        children: [
                          ProductImage(
                            assetPath: sub.imageAsset,
                            icon: Icons.medication_outlined,
                            letter: sub.name,
                            width: 52,
                            height: 52,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sub.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                PriceText(
                                  pricePaise: sub.price,
                                  mrpPaise: sub.mrp,
                                  style: AppTypography.price.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shimmer placeholder for the detail page.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        ShimmerBox(height: 240),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(height: 28, width: 220),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(height: 16, width: 160),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(height: 22, width: 120),
        SizedBox(height: AppSpacing.lg),
        ShimmerBox(height: 72),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(height: 72),
      ],
    );
  }
}
