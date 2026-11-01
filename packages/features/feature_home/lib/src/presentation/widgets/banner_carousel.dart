import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/home_banner.dart';

/// Auto-advancing, looping promo carousel with animated page dots. Pauses
/// while the user drags.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners});

  final List<HomeBanner> banners;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const _interval = Duration(seconds: 4);
  // Start far from 0 so the user can also swipe backwards "infinitely".
  static const _startPage = 600;

  final _controller = PageController(
    initialPage: _startPage,
    viewportFraction: 0.92,
  );
  Timer? _timer;
  int _page = _startPage;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) => _advance());
  }

  void _advance() {
    if (_dragging || !_controller.hasClients || widget.banners.length < 2) {
      return;
    }
    _controller.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _open(HomeBanner banner) {
    final id = banner.categoryId;
    if (id == null) {
      context.go(RoutePaths.categories);
      return;
    }
    final name = Uri.encodeQueryComponent(banner.categoryName ?? '');
    context.push('${RoutePaths.categoryProducts(id)}?name=$name');
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners.isEmpty) return const SizedBox.shrink();
    final active = _page % banners.length;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification) {
                _dragging = n.dragDetails != null;
              }
              if (n is ScrollEndNotification) _dragging = false;
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final banner = banners[index % banners.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _BannerCard(
                    banner: banner,
                    onTap: () => _open(banner),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == active ? 20 : 6,
                decoration: BoxDecoration(
                  color: i == active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final HomeBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            banner.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.primaryDark),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xDD00332E), Color(0x2200332E)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  banner.subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
                const SizedBox(height: AppSpacing.sm + 4),
                ActionChip(
                  onPressed: onTap,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    banner.ctaLabel,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
