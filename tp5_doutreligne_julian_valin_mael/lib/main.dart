import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste de Courses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ShoppingListScreen(),
    );
  }
}

// Modèle pour un produit dans la liste
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

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<CartProduct> _cartProducts = [];

  void _addProduct(CartProduct product) {
    setState(() {
      // Vérifier si le produit existe déjà
      final existingIndex = _cartProducts.indexWhere(
        (p) => p.barcode == product.barcode,
      );

      if (existingIndex != -1) {
        // Incrémenter la quantité si le produit existe
        _cartProducts[existingIndex].quantity++;
      } else {
        // Ajouter le nouveau produit
        _cartProducts.add(product);
      }
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _cartProducts.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartProducts[index].quantity += delta;
      if (_cartProducts[index].quantity <= 0) {
        _cartProducts.removeAt(index);
      }
    });
  }

  void _clearList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider la liste'),
        content: const Text('Voulez-vous vraiment vider toute la liste ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartProducts.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  double get _totalPrice {
    return _cartProducts.fold(0.0, (sum, product) {
      return sum + ((product.price ?? 0.0) * product.quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Liste de Courses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_cartProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Vider la liste',
              onPressed: _clearList,
            ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner un produit',
            onPressed: () async {
              final product = await Navigator.push<CartProduct>(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerScreen(),
                ),
              );
              if (product != null) {
                _addProduct(product);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Votre liste est vide',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scannez un produit pour commencer',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _cartProducts.length,
                    itemBuilder: (context, index) {
                      final product = _cartProducts[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image du produit
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              // Informations du produit
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
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Nutri-Score
                                        if (product.nutriscoreGrade != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getNutriscoreColor(
                                                product.nutriscoreGrade!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Nutri-Score ${product.nutriscoreGrade!.toUpperCase()}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        const Spacer(),
                                        // Prix
                                        if (product.price != null)
                                          Text(
                                            '${(product.price! * product.quantity).toStringAsFixed(2)} €',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.teal,
                                            ),
                                          )
                                        else
                                          const Text(
                                            'Prix non disponible',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Contrôles de quantité
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () => _updateQuantity(index, 1),
                                    iconSize: 28,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '${product.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      product.quantity > 1
                                          ? Icons.remove_circle
                                          : Icons.delete,
                                      color: product.quantity > 1
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                    onPressed: () => _updateQuantity(index, -1),
                                    iconSize: 28,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Barre de total
          if (_cartProducts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
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
                        ),
                      ),
                      Text(
                        '${_cartProducts.length} article(s)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getNutriscoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF038141);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFECB02);
      case 'd':
        return const Color(0xFFEE8100);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }
}

// Écran de scan de code-barres
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  XFile? _selectedImage;
  bool _isScanning = false;
  bool _isFetchingProduct = false;

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _scanBarcodeFromImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _isScanning = true;
        });

        final inputImage = InputImage.fromFilePath(pickedFile.path);
        final barcodes = await _barcodeScanner.processImage(inputImage);

        setState(() {
          _isScanning = false;
        });

        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
          await _fetchProductInfo(barcodes.first.rawValue!);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aucun code-barre détecté'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _fetchProductInfo(String barcode) async {
    setState(() {
      _isFetchingProduct = true;
    });

    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.net/api/v2/product/$barcode.json',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('off:off'))}',
        },
      );

      setState(() {
        _isFetchingProduct = false;
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 1) {
          final productData = jsonData['product'];

          // Créer un produit avec les données récupérées
          final product = CartProduct(
            barcode: barcode,
            name: productData['product_name'] ?? 'Produit inconnu',
            brand: productData['brands'],
            imageUrl: productData['image_url'],
            nutriscoreGrade: productData['nutriscore_grade'],
            price: _extractPrice(productData),
          );

          if (mounted) {
            Navigator.pop(context, product);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produit non trouvé dans la base OpenFoodFacts'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur serveur: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isFetchingProduct = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de connexion: $e')));
      }
    }
  }

  double? _extractPrice(Map<String, dynamic> productData) {
    // OpenFoodFacts ne fournit pas toujours le prix
    // Pour la démo, générer un prix basé sur le hash du nom
    if (productData['product_name'] != null) {
      final hash = productData['product_name'].hashCode.abs();
      return (hash % 1900 + 100) / 100.0; // Entre 1.00 et 20.00€
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un produit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune image sélectionnée',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              if (_isScanning || _isFetchingProduct)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _isScanning
                          ? 'Scan en cours...'
                          : 'Récupération des informations...',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _scanBarcodeFromImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 28),
                        label: const Text(
                          'Prendre une photo',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _scanBarcodeFromImage(ImageSource.gallery),
                        icon: const Icon(Icons.image, size: 28),
                        label: const Text(
                          'Choisir depuis la galerie',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Scannez le code-barre d\'un produit alimentaire pour l\'ajouter à votre liste',
                        style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
