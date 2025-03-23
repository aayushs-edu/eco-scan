import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the list of available cameras
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(EcoScanApp(camera: firstCamera));
}

class EcoScanApp extends StatelessWidget {
  final CameraDescription camera;

  const EcoScanApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.green, // Use a green color for EcoScan theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

  Color bgColor = Colors.black38;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(         'EcoScan',
          style: GoogleFonts.cantoraOne(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        backgroundColor: bgColor,
        centerTitle: true,
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.green),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  // Camera preview covering most of the screen
                  Positioned.fill(
                    bottom: 140,
                    child: ElevatedButton(
                      onPressed: () async {
                        SimpleBarcodeScanner.streamBarcode(
                            context,
                            barcodeAppBar: const BarcodeAppBar(
                              appBarTitle: 'Test',
                              centerTitle: false,
                              enableBackButton: true,
                              backButtonIcon: Icon(Icons.arrow_back_ios),
                            ),
                            isShowFlashIcon: true,
                            delayMillis: 2000,
                        ).listen((event) {
                          print("Stream Barcode Result: $event");
                        });
                      },
                      child: const Text('Open Scanner'),
                    ),
                  ),
                  // Overlay for the button
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                        onPressed: _scanBarcode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Scan Barcode',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
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
      ),
    );
  }
}
