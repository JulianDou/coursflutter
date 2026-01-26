import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
      title: 'Barcode Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BarcodeScannerScreen(),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  List<Barcode> _scannedBarcodes = [];
  XFile? _selectedImage;
  bool _isScanning = false;
  Map<String, dynamic>? _productData;
  bool _isFetchingProduct = false;

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _fetchProductInfo(String barcode) async {
    setState(() {
      _isFetchingProduct = true;
      _productData = null;
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

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 1) {
          setState(() {
            _productData = jsonData['product'];
            _isFetchingProduct = false;
          });
        } else {
          setState(() {
            _isFetchingProduct = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produit non trouvé dans la base OpenFoodFacts'),
              ),
            );
          }
        }
      } else {
        setState(() {
          _isFetchingProduct = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.statusCode}')),
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

  Future<void> _scanBarcodeFromImage(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera permission denied')),
            );
          }
          return;
        }
      } else {
        final storageStatus = await Permission.photos.request();
        if (!storageStatus.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')),
            );
          }
          return;
        }
      }

      final XFile? pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _isScanning = true;
        });

        print('Processing image: ${pickedFile.path}');
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        final barcodes = await _barcodeScanner.processImage(inputImage);

        print('Barcodes found: ${barcodes.length}');
        for (int i = 0; i < barcodes.length; i++) {
          print('Barcode $i: ${barcodes[i].rawValue}');
        }

        if (mounted) {
          setState(() {
            _scannedBarcodes = barcodes;
            _isScanning = false;
          });
        }

        // Si un code-barre de type produit est détecté, récupérer les infos
        if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
          await _fetchProductInfo(barcodes.first.rawValue!);
        }
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _clearResults() {
    setState(() {
      _selectedImage = null;
      _scannedBarcodes = [];
      _productData = null;
    });
  }

  String _getBarcodeTypeString(BarcodeType type) {
    if (type == BarcodeType.product) {
      return 'Product';
    } else if (type == BarcodeType.wifi) {
      return 'WiFi';
    } else if (type == BarcodeType.url) {
      return 'URL';
    } else if (type == BarcodeType.email) {
      return 'Email';
    } else if (type == BarcodeType.phone) {
      return 'Phone';
    } else if (type == BarcodeType.sms) {
      return 'SMS';
    } else if (type == BarcodeType.contactInfo) {
      return 'Contact';
    } else if (type == BarcodeType.calendarEvent) {
      return 'Event';
    } else if (type == BarcodeType.driverLicense) {
      return 'Driver License';
    } else if (type == BarcodeType.unknown) {
      return 'Unknown';
    } else {
      return type.name;
    }
  }

  Widget _buildProductInfo(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value.toString()),
          ],
        ),
      ),
    );
  }

  Color _getNutriscoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.yellow[700]!;
      case 'd':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedImage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                if (_scannedBarcodes.isEmpty && _selectedImage == null)
                  Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_isScanning)
                  const CircularProgressIndicator()
                else if (_scannedBarcodes.isEmpty && _selectedImage != null)
                  const Text('No barcodes detected')
                else if (_scannedBarcodes.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'Found ${_scannedBarcodes.length} barcode(s):',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _scannedBarcodes
                            .map((b) => b.rawValue ?? 'No value')
                            .join('\n'),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        _scannedBarcodes
                            .map((b) =>
                                'Type: ${_getBarcodeTypeString(b.type)}, Format: ${b.format.name}')
                            .join('\n'),
                        style: const TextStyle(fontSize: 14),
                      )
                    ]
                  ),
                  // Expanded(
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: _scannedBarcodes.length,
                  //     itemBuilder: (context, index) {
                  //       final barcode = _scannedBarcodes[index];
                  //       return Card(
                  //         margin: const EdgeInsets.symmetric(vertical: 8),
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(12.0),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 'Barcode ${index + 1}',
                  //                 style: const TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 16,
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 8),
                  //               Text(
                  //                 'Type: ${_getBarcodeTypeString(barcode.type)}',
                  //                 style: const TextStyle(fontSize: 14),
                  //               ),
                  //               const SizedBox(height: 4),
                  //               Text(
                  //                 'Format: ${barcode.format.name}',
                  //                 style: const TextStyle(fontSize: 14),
                  //               ),
                  //               const SizedBox(height: 8),
                  //               Container(
                  //                 padding: const EdgeInsets.all(8),
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.grey[200],
                  //                   borderRadius: BorderRadius.circular(4),
                  //                 ),
                  //                 child: SelectableText(
                  //                   barcode.rawValue ?? 'No value',
                  //                   style: const TextStyle(
                  //                     fontFamily: 'monospace',
                  //                     fontSize: 12,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                const SizedBox(height: 20),
                // Affichage des informations du produit OpenFoodFacts
                if (_isFetchingProduct)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Récupération des informations du produit...'),
                    ],
                  )
                else if (_productData != null)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations du produit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Divider(),
                          if (_productData!['image_url'] != null)
                            Center(
                              child: Image.network(
                                _productData!['image_url'],
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 12),
                          _buildProductInfo(
                            'Nom',
                            _productData!['product_name'],
                          ),
                          _buildProductInfo('Marque', _productData!['brands']),
                          _buildProductInfo(
                            'Catégories',
                            _productData!['categories'],
                          ),
                          _buildProductInfo(
                            'Quantité',
                            _productData!['quantity'],
                          ),
                          if (_productData!['nutriscore_grade'] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Nutri-Score: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getNutriscoreColor(
                                        _productData!['nutriscore_grade'],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _productData!['nutriscore_grade']
                                          .toString()
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildProductInfo(
                            'Ingrédients',
                            _productData!['ingredients_text'],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isScanning
                          ? null
                          : () => _scanBarcodeFromImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isScanning
                          ? null
                          : () => _scanBarcodeFromImage(ImageSource.gallery),
                      icon: const Icon(Icons.image),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: _clearResults,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
