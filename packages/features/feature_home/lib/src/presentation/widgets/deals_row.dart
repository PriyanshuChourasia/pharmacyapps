import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'product_row.dart';

/// "Deals of the day" header with a countdown to midnight, plus the row.
class DealsRow extends StatelessWidget {
  const DealsRow({
    super.key,
    required this.products,
    required this.cartQty,
    required this.onAdd,
    required this.onQtyChanged,
    required this.onTap,
  });

  final List<Product> products;
  final Map<String, int> cartQty;
  final Future<String?> Function(Product product) onAdd;
  final Future<String?> Function(String productId, int qty) onQtyChanged;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Deals of the day', trailing: _Countdown()),
        // Hero off: deal products can also appear in other Home sections.
        ProductRow(
          products: products,
          cartQty: cartQty,
          onAdd: onAdd,
          onQtyChanged: onQtyChanged,
          onTap: onTap,
          hero: false,
          showDiscountRibbon: true,
        ),
      ],
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown();

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late Timer _timer;
  Duration _left = _untilMidnight();

  static Duration _untilMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1).difference(now);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _left = _untilMidnight()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final text =
        '${two(_left.inHours)}:${two(_left.inMinutes % 60)}:'
        '${two(_left.inSeconds % 60)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'Ends in $text',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
