import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:universal_html/html.dart' as html;
import 'js_interop.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String _scannedBarcode = 'Scanning...';

  @override
  void initState() {
    super.initState();
    _initBarcodeScanner();
  }

  void _initBarcodeScanner() {
    init(allowInterop(() {
      final videoElement = html.document.querySelector('video') as html.VideoElement;
      start(videoElement, allowInterop((barcode) {
        setState(() {
          _scannedBarcode = barcode;
        });
      }));
    }));
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner')),
      body: Column(
        children: [
          Expanded(
            child: HtmlElementView(viewType: 'video-preview'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Scanned Barcode: $_scannedBarcode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}