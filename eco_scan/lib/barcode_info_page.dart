import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'barcodeInfo.dart';

class BarcodeInfoPage extends StatefulWidget {
  final String barcode;

  const BarcodeInfoPage({Key? key, required this.barcode}) : super(key: key);

  @override
  _BarcodeInfoPageState createState() => _BarcodeInfoPageState();
}

class _BarcodeInfoPageState extends State<BarcodeInfoPage> {
  late Future<BarcodeInfo> _barcodeInfo;

  @override
  void initState() {
    super.initState();
    _barcodeInfo = fetchBarcodeInfo(widget.barcode);
  }

  Future<BarcodeInfo> fetchBarcodeInfo(String barcode) async {
    final response = await http.get(
      Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'),
      headers: {"Access-Control-Allow-Origin": "*"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return BarcodeInfo.fromMap(data['items'][0]);
      } else {
        throw Exception('No items found for this barcode');
      }
    } else {
      throw Exception('Failed to load barcode info');
    }
  }

  // Future<String> fetchBrandName(String barcode) async {
  //   final response = await http.get(
  //     Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'),
  //     headers: {"Access-Control-Allow-Origin": "*"},
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data['total'] > 0) {
  //       if (data['items'] != null && data['items'].isNotEmpty) {
  //         final productResponse = ProductResponse.fromMap(data);
  //         return productResponse.items.first.brand;
  //       } else {
  //         throw Exception('No items found for this barcode');
  //       }
  //     } else {
  //       throw Exception('No items found for this barcode');
  //     }
  //   } else {
  //     print(response.statusCode);
  //     print(response.body);
  //     throw Exception('Failed to load brand name');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Info'),
      ),
      body: FutureBuilder<BarcodeInfo>(
        future: _barcodeInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the API call is in progress
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message if the API call fails
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData) {
            // Handle the case where no data is returned
            return Center(
              child: Text(
                'No data found for this barcode.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            // Display the barcode information when the API call succeeds
            final info = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Text('Brand: ${info.brand}', style: TextStyle(fontSize: 18)),
                Text('Name: ${info.title}', style: TextStyle(fontSize: 18)),
                Text('Category: ${info.category}', style: TextStyle(fontSize: 18)),
                // Add more fields as needed
              ],
            );
          }
        },
      ),
    );
  }
}