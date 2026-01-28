import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/glass_morphism.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'models/product.dart';
import 'models/shopping_list.dart';
import 'models/cart_product.dart';
import 'pages/saved_lists_page.dart';
import 'pages/settings_page.dart';
import 'services/storage_service.dart';
import 'services/settings_service.dart';
import 'widgets/product_card.dart';
import 'widgets/empty_cart_state.dart';
import 'widgets/cart_summary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsService _settingsService = SettingsService();
  bool _performanceMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final performanceMode = await _settingsService.getPerformanceMode();
    setState(() {
      _performanceMode = performanceMode;
      _isLoading = false;
    });
  }

  void _updatePerformanceMode(bool value) {
    setState(() {
      _performanceMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Liste de Courses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: ShoppingListScreen(
        performanceMode: _performanceMode,
        onPerformanceModeChanged: _updatePerformanceMode,
      ),
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  final bool performanceMode;
  final Function(bool) onPerformanceModeChanged;

  const ShoppingListScreen({
    super.key,
    required this.performanceMode,
    required this.onPerformanceModeChanged,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<CartProduct> _cartProducts = [];
  final StorageService _storage = StorageService();

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

  String get _averageNutriscore {
    final grades = _cartProducts
        .where((p) => p.nutriscoreGrade != null)
        .map((p) => p.nutriscoreGrade!.toLowerCase())
        .toList();
    if (grades.isEmpty) return 'N/A';

    final gradeValues = {'a': 5, 'b': 4, 'c': 3, 'd': 2, 'e': 1};
    final total = grades.fold<int>(
      0,
      (sum, grade) => sum + (gradeValues[grade] ?? 0),
    );
    final averageValue = total / grades.length;

    // Trouver la lettre correspondant à la valeur moyenne
    String averageGrade = 'N/A';
    gradeValues.forEach((key, value) {
      if (averageValue >= value) {
        averageGrade = key.toUpperCase();
        return;
      }
    });

    return averageGrade;
  }

  Future<void> _saveCurrentList() async {
    if (_cartProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('La liste est vide')));
      return;
    }
    final now = DateTime.now();
    final name =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final products = _cartProducts
        .map(
          (c) => Product(
            id: c.barcode,
            name: c.name,
            price: (c.price ?? 0.0),
            quantity: c.quantity,
          ),
        )
        .toList();
    final list = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      products: products,
    );
    await _storage.addList(list);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Liste enregistrée: "$name"')));
  }

  Future<void> _browseSavedLists() async {
    final result = await Navigator.of(context).push<ShoppingList?>(
      MaterialPageRoute(
        builder: (_) => SavedListsPage(performanceMode: widget.performanceMode),
      ),
    );
    if (result != null) {
      setState(() {
        _cartProducts
          ..clear()
          ..addAll(
            result.products.map(
              (p) => CartProduct(
                barcode: p.id,
                name: p.name,
                price: p.price,
                quantity: p.quantity,
              ),
            ),
          );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Liste chargée: "${result.name}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Liste de Courses'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    performanceMode: widget.performanceMode,
                    onPerformanceModeChanged: widget.onPerformanceModeChanged,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Listes enregistrées',
            onPressed: _browseSavedLists,
          ),
          if (_cartProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Vider la liste',
              onPressed: _clearList,
            ),
          if (_cartProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Enregistrer la liste',
              onPressed: _saveCurrentList,
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
      body: GradientBackground(
        performanceMode: widget.performanceMode,
        child: Column(
          children: [
            Expanded(
              child: _cartProducts.isEmpty
                  ? EmptyCartState(performanceMode: widget.performanceMode)
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _cartProducts.length,
                      itemBuilder: (context, index) {
                        final product = _cartProducts[index];
                        return ProductCard(
                          product: product,
                          performanceMode: widget.performanceMode,
                          onIncrement: () => _updateQuantity(index, 1),
                          onDecrement: () => _updateQuantity(index, -1),
                        );
                      },
                    ),
            ),
            // Barre de total
            if (_cartProducts.isNotEmpty)
              CartSummary(
                itemCount: _cartProducts.length,
                totalPrice: _totalPrice,
                averageNutriscore: _averageNutriscore,
                performanceMode: widget.performanceMode,
              ),
          ],
        ),
      ),
    );
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
        backgroundColor: Colors.white,
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
                    child: kIsWeb
                        ? Image.network(
                            _selectedImage!.path,
                            height: 300,
                            width: 300,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
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
