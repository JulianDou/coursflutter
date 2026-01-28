import 'package:flutter/material.dart';
import 'glass_morphism.dart';
import 'nutriscore_badge.dart';

class CartSummary extends StatelessWidget {
  final int itemCount;
  final double totalPrice;
  final String averageNutriscore;

  const CartSummary({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.averageNutriscore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$itemCount article(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Text(
                  '${totalPrice.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nutri-Score moyen :',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                NutriscoreBadge(grade: averageNutriscore, fontSize: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
