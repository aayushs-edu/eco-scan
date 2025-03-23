import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

void main() {
  runApp(EcoScannerApp());
}

class EcoScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoScanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BarcodeScannerScreen(camera: camera),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  final CameraDescription camera;

  const BarcodeScannerScreen({super.key, required this.camera});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  void _processBarcode(InputImage inputImage) async {
    if (isProcessing) return;
    isProcessing = true;

    final barcodes = await _barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final String barcodeValue = barcode.rawValue ?? 'No value found';
      print('Barcode found! Value: $barcodeValue');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode: $barcodeValue')),
      );
    }

    isProcessing = false;
  }

  Future<void> _scanBarcode() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      _processBarcode(inputImage);
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _scanBarcode,
                      child: const Text('Scan Barcode'),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
