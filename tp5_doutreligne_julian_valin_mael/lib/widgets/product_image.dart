import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(Icons.image_not_supported);
              },
            )
          : _buildPlaceholder(Icons.shopping_bag),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Icon(
        icon,
        color: Colors.grey,
      ),
    );
  }
}
