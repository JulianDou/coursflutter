import 'package:flutter/material.dart';
import '../models/cart_product.dart';
import 'glass_morphism.dart';
import 'product_image.dart';
import 'nutriscore_badge.dart';
import 'quantity_controls.dart';

class ProductCard extends StatelessWidget {
  final CartProduct product;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool performanceMode;

  const ProductCard({
    super.key,
    required this.product,
    required this.onIncrement,
    required this.onDecrement,
    this.performanceMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassContainer(
        borderRadius: 12,
        performanceMode: performanceMode,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(imageUrl: product.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.brand!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (product.nutriscoreGrade != null)
                        NutriscoreBadge(grade: product.nutriscoreGrade!),
                      const Spacer(),
                      if (product.price != null)
                        Text(
                          '${(product.price! * product.quantity).toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        )
                      else
                        Text(
                          'Prix non disponible',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            QuantityControls(
              quantity: product.quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
      ),
    );
  }
}
