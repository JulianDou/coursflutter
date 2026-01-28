class CartProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? nutriscoreGrade;
  final double? price;
  int quantity;

  CartProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.nutriscoreGrade,
    this.price,
    this.quantity = 1,
  });
}
