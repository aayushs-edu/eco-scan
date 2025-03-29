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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Darkchocolate ganache heart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Godiva',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildSection(
            title: 'Health',
            children: [
              _buildTile(
                title: 'Nutrition',
                subtitle: 'Nutri-Score UNKNOWN',
                icon: Icons.fastfood,
              ),
              _buildTile(
                title: 'Nutrition facts',
                subtitle: 'Serving size: 3 pieces (26 g)',
                icon: Icons.info_outline,
              ),
              _buildTile(
                title: 'Ingredients',
                subtitle: '17 ingredients',
                icon: Icons.restaurant_menu,
              ),
              _buildTile(
                title: 'Food processing',
                subtitle: 'Tap here to answer questions',
                icon: Icons.question_answer,
              ),
            ],
          ),
          _buildSection(
            title: 'Environment',
            children: [
              _buildTile(
                title: 'Green-Score not computed',
                subtitle: '',
                icon: Icons.eco,
              ),
              _buildTile(
                title: 'Packaging',
                subtitle: 'Missing packaging information',
                icon: Icons.local_shipping,
              ),
              _buildTile(
                title: 'Transportation',
                subtitle: 'Missing origins of ingredients',
                icon: Icons.public,
              ),
              _buildTile(
                title: 'Threatened species',
                subtitle: 'Tap here to answer questions',
                icon: Icons.warning,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomButton(Icons.edit, 'Edit', () {}),
              _buildBottomButton(Icons.attach_money, 'Add a price', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set the text color to white
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildTile({required String title, String? subtitle, IconData? icon}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null && subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
    );
  }

  Widget _buildBottomButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}