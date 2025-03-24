import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  /// This function calls an external API to fetch the brand name from the barcode.
  /// In this example, we use UPCItemDB’s trial endpoint.
  Future<String> fetchBrandName(String barcode) async {
    final url = 'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final brand = data['items'][0]['brand'];
          return (brand != null && (brand as String).isNotEmpty)
              ? brand
              : 'Unknown brand';
        }
      }
      return 'Unknown brand';
    } catch (e) {
      debugPrint("Error fetching brand: $e");
      return 'Unknown brand';
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
                final String? scannedValue = capture.barcodes.first.rawValue;
                if (scannedValue != null) {
                  debugPrint("Barcode scanned: $scannedValue");
                  // Fetch the brand name for the scanned barcode.
                  final brand = await fetchBrandName(scannedValue);
                  setState(() {
                    _barcodeResult =
                        "Barcode: $scannedValue\nBrand: $brand";
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Brand: $brand')),
                  );
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
                child: Container(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
