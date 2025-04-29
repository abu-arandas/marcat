import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Map<String, String>> _dummyProducts = [
    {'name': 'Product 1', 'id': '1'},
    {'name': 'Product 2', 'id': '2'},
    {'name': 'Product 3', 'id': '3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: ListView.builder(
        itemCount: _dummyProducts.length,
        itemBuilder: (context, index) {
          final product = _dummyProducts[index];
          return ListTile(
            title: Text(product['name']!),
            subtitle: Text('ID: ${product['id']!}'),
          );
        },
      ),
    );
  }
}