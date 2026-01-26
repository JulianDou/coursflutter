import 'dart:convert';

import 'product.dart';

class ShoppingList {
  final String id;
  String name;
  final List<Product> products;

  ShoppingList({
    required this.id,
    required this.name,
    required this.products,
  });

  int get productCount => products.fold<int>(0, (sum, p) => sum + p.quantity);
  double get totalPrice => products.fold<double>(0.0, (sum, p) => sum + p.total);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'products': products.map((p) => p.toMap()).toList(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] as String,
      name: (map['name'] ?? '') as String,
      products: (map['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());
  factory ShoppingList.fromJson(String source) =>
      ShoppingList.fromMap(json.decode(source) as Map<String, dynamic>);
}
