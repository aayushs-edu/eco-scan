import 'package:flutter/material.dart';
import 'scanner_screen.dart';

void main() {
  runApp(EcoScannerApp());
}

class EcoScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoScanner',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ScannerScreen(),
    );
  }
}