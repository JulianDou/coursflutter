import 'package:flutter/material.dart';
import 'glass_morphism.dart';

class EmptyCartState extends StatelessWidget {
  const EmptyCartState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 16),
            Text(
              'Votre liste est vide',
              style: TextStyle(
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scannez un produit pour commencer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
