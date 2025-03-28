import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'barcodeInfo.dart';
import 'barcode_info_page.dart'; // Add this import

void main() {
  runApp(const EcoScanApp());
}

class EcoScanApp extends StatelessWidget {
  const EcoScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BarcodeScannerScreen(),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String _barcodeResult = "No barcode scanned yet";
  final Color bgColor = Colors.black38;
  final TextEditingController _gtinController = TextEditingController();

  void _navigateToBarcodeInfoPage(String barcode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeInfoPage(barcode: barcode),
      ),
    );
  }

  /// This function calls an external API to fetch the brand name from the barcode.
  /// In this example, we use UPCItemDB’s trial endpoint.
  Future<String> fetchBrandName(String barcode) async {
    final response = await http.get(
      Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'),
      headers: {"Access-Control-Allow-Origin": "*"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final productResponse = ProductResponse.fromMap(data);
      return productResponse.items.first.brand;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load brand name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'EcoScan',
          style: GoogleFonts.cantoraOne(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: bgColor,
        centerTitle: true,
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.green),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // AiBarcodeScanner widget provided by ai_barcode_scanner package.
            AiBarcodeScanner(
              onDispose: () {
                debugPrint("Barcode scanner disposed!");
              },
              hideGalleryButton: false,
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
              ),
              onDetect: (BarcodeCapture capture) async {
                if (capture.barcodes.isNotEmpty) {
                  final String? scannedValue = capture.barcodes.first.rawValue;
                  if (scannedValue != null) {
                    debugPrint("Barcode scanned: $scannedValue");
                    _navigateToBarcodeInfoPage(scannedValue);
                  } else {
                    debugPrint("Scanned value is null.");
                  }
                } else {
                  debugPrint("No barcodes detected.");
                }
              },
              // You can modify or remove this validator as needed.
              validator: (value) {
                if (value.barcodes.isEmpty) {
                  return false;
                }
                // For example, only accept barcodes containing 'flutter.dev'
                if (!(value.barcodes.first.rawValue
                        ?.contains('flutter.dev') ??
                    false)) {
                  return false;
                }
                return true;
              },
            ),
            // Overlay to display the scanned barcode result.
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _barcodeResult,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _gtinController,
                        decoration: InputDecoration(
                          hintText: 'Enter GTIN',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            _navigateToBarcodeInfoPage(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
