import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final ProductService _productService = ProductService();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Catalog')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Search products', border: OutlineInputBorder()),
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data ?? [];
                  final filtered = products.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();
                  if (filtered.isEmpty) return const Center(child: Text('No products found'));
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return ProductCard(product: product, onAdd: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart'))));
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
