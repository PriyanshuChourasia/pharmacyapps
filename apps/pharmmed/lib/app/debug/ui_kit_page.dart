import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Temporary debug page showcasing every design-system widget and animation,
/// so they can be reviewed visually during development. Debug-only: the
/// route is registered only when [kDebugMode] is true and the only entry
/// point is the Profile tab.
class UiKitPage extends StatefulWidget {
  const UiKitPage({super.key});

  @override
  State<UiKitPage> createState() => _UiKitPageState();
}

class _UiKitPageState extends State<UiKitPage> {
  int _qty = 2;
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI kit (debug)')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _SectionTitle('Buttons'),
          AppButton(
            label: 'Primary — Add to cart',
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Secondary',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Ghost',
            variant: AppButtonVariant.ghost,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(label: 'Loading', loading: true, onPressed: () {}),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: AppButton(label: 'Disabled')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Product images (asset + fallback)'),
          Row(
            children: [
              Expanded(
                child: ProductImage(
                  assetPath: 'assets/images/products/tablet_strip.jpg',
                  icon: Icons.local_pharmacy_outlined,
                  letter: 'D',
                  height: 96,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ProductImage(
                  assetPath: 'assets/images/products/syrup_bottle.jpg',
                  icon: Icons.science_outlined,
                  letter: 'C',
                  height: 96,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Missing asset → colored placeholder with icon + letter.
              const Expanded(
                child: ProductImage(
                  assetPath: null,
                  icon: Icons.medication_outlined,
                  letter: 'P',
                  height: 96,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Prices & Rx badge'),
          const PriceText(pricePaise: 13500, mrpPaise: 15000),
          const SizedBox(height: AppSpacing.sm),
          const PriceText(pricePaise: 49900),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              RxBadge(),
              SizedBox(width: AppSpacing.sm),
              Text('Prescription required'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Quantity stepper (animated count)'),
          QuantityStepper(
            value: _qty,
            onChanged: (next) => setState(() => _qty = next),
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Cart badge pop (tap to add)'),
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BadgePop(
                count: _count,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.rx,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ActionChip(
                label: const Text('Add'),
                onPressed: () => setState(() => _count++),
              ),
              ActionChip(
                label: const Text('Reset'),
                onPressed: () => setState(() => _count = 0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Shimmer skeleton (loading)'),
          Row(
            children: [
              const Expanded(
                child: ShimmerBox(height: 96),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(height: 16, width: 120),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerBox(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Staggered entrance (tiles appear in order)'),
          Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < 3 ? AppSpacing.sm : 0,
                    ),
                    child: StaggeredFadeIn(
                      index: i,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        alignment: Alignment.center,
                        child: Text('${i + 1}'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Empty state'),
          const EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            message: 'Add medicines to get started.',
            actionLabel: 'Browse medicines',
          ),
          const SizedBox(height: AppSpacing.lg),

          const _SectionTitle('Loading view'),
          const SizedBox(height: 72, child: LoadingView(message: 'Loading…')),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTypography.sectionTitle),
    );
  }
}
