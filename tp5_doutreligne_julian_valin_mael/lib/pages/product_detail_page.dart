import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_product.dart';
import '../widgets/product_image.dart';
import '../widgets/nutriscore_badge.dart';

class ProductDetailPage extends StatefulWidget {
  final CartProduct product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? _offProduct;
  bool _loading = true;
  bool _notFound = false;
  int? _cachedAt;

  static const _ttlMs = 24 * 60 * 60 * 1000; // 24h

  @override
  void initState() {
    super.initState();
    _loadCacheAndMaybeFetch();
  }

  Future<void> _loadCacheAndMaybeFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'off_${widget.product.barcode}';
    final cached = prefs.getString(key);
    if (cached != null) {
      try {
        final Map parsed = jsonDecode(cached) as Map;
        _cachedAt = parsed['timestamp'] as int?;
        _offProduct = (parsed['data'] as Map?)?.cast<String, dynamic>();
      } catch (_) {}
    }
    setState(() {
      _loading = _offProduct == null;
      _notFound = false;
    });

    final now = DateTime.now().millisecondsSinceEpoch;
    if (_cachedAt == null || (now - (_cachedAt ?? 0)) > _ttlMs) {
      await _fetchAndCache();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchAndCache() async {
    setState(() => _loading = true);
    final barcode = widget.product.barcode;
    final url = Uri.parse('https://world.openfoodfacts.net/api/v2/product/$barcode.json');
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final Map jsonData = jsonDecode(resp.body) as Map;
        final productData = (jsonData['product'] as Map?)?.cast<String, dynamic>();
        if (productData != null && productData.isNotEmpty) {
          _offProduct = productData;
          _cachedAt = DateTime.now().millisecondsSinceEpoch;
          final prefs = await SharedPreferences.getInstance();
          final key = 'off_${widget.product.barcode}';
          await prefs.setString(key, jsonEncode({'timestamp': _cachedAt, 'data': _offProduct}));
          setState(() {
            _notFound = false;
            _loading = false;
          });
          return;
        }
      }
      setState(() {
        _notFound = true;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _manualRefresh() async {
    await _fetchAndCache();
  }

  Widget _buildOffInfo() {
    if (_loading && _offProduct == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notFound && _offProduct == null) {
      return const Text('Produit non trouvé dans la base OpenFoodFacts.');
    }
    if (_offProduct == null) {
      return const SizedBox.shrink();
    }

    final ingredients = _offProduct!['ingredients_text'] as String?;
    final allergens = _offProduct!['allergens'] as String?;
    final labels = _offProduct!['labels'] as String?;
    final quantity = _offProduct!['quantity'] as String?;
    final packaging = _offProduct!['packaging'] as String?;
    final categories = _offProduct!['categories'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ingredients != null && ingredients.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Ingrédients', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(ingredients),
        ],
        if (allergens != null && allergens.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Allergènes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(allergens),
        ],
        if (labels != null && labels.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Labels', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(labels),
        ],
        if (categories != null && categories.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Catégories', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(categories),
        ],
        if (quantity != null && quantity.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Quantité déclarée', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(quantity),
        ],
        if (packaging != null && packaging.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Emballage', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(packaging),
        ],
        
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              width: double.infinity,
              child: ProductImage(imageUrl: product.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (product.brand != null) ...[
              const SizedBox(height: 6),
              Text(product.brand!, style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (product.nutriscoreGrade != null)
                  NutriscoreBadge(grade: product.nutriscoreGrade!),
                const Spacer(),
                if (product.price != null)
                  Text(
                    '${product.price!.toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Code-barres: ${product.barcode}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Text('Quantité: ${product.quantity}'),
            const SizedBox(height: 24),
            const Text('Informations OpenFoodFacts', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildOffInfo(),
          ],
        ),
      ),
    );
  }
}
