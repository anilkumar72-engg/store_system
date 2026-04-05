import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? _editingId;

  void _resetForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _stockController.clear();
      _barcodeController.clear();
      _imageUrlController.clear();
    });
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());
    final barcode = _barcodeController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product name is required.')));
      return;
    }
    if (category.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Category is required.')));
      return;
    }
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid numeric price.')));
      return;
    }
    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid numeric stock.')));
      return;
    }

    final product = ProductModel(
      id: _editingId ?? '',
      name: name,
      description: '$name details',
      category: category,
      price: price,
      stock: stock,
      barcode: barcode,
      imageUrl: imageUrl,
      createdAt: Timestamp.now(),
    );

    if (_editingId != null) {
      await _productService.updateProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully.')));
    } else {
      await _productService.addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully.')));
    }
    _resetForm();
  }

  void _startEdit(ProductModel product) {
    setState(() {
      _editingId = product.id;
      _nameController.text = product.name;
      _categoryController.text = product.category;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _barcodeController.text = product.barcode;
      _imageUrlController.text = product.imageUrl;
    });
  }

  Future<void> _deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    if (_editingId == id) _resetForm();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Product deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    void navigateTo(String route) {
      Navigator.pushReplacementNamed(context, route);
    }

    return Scaffold(
      appBar: const TopBar(title: 'Admin - Product Management'),
      body: Row(
        children: [
          AppSidebar(selected: AppRoutes.adminProducts, onSelect: navigateTo),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manage Products',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Product Name',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: _categoryController,
                                  decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder()))),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Price',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Stock',
                                      border: OutlineInputBorder()))),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: _barcodeController,
                                  decoration: const InputDecoration(
                                      labelText: 'Barcode',
                                      border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: _imageUrlController,
                                  decoration: const InputDecoration(
                                      labelText: 'Image URL',
                                      border: OutlineInputBorder()))),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          ElevatedButton(
                              onPressed: _saveProduct,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32)),
                              child: Text(_editingId == null
                                  ? 'Save Product'
                                  : 'Update Product')),
                          const SizedBox(width: 12),
                          if (_editingId != null)
                            TextButton(
                                onPressed: _resetForm,
                                child: const Text('Cancel')),
                        ]),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Product List',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<ProductModel>>(
                      stream: _productService.getProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return const Center(
                              child: Text('No products available.'));
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.only(top: 5),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: product.imageUrl.isNotEmpty
                                        ? Image.network(product.imageUrl,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover)
                                        : Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image,
                                                color: Colors.grey)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(product.name,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          Text(product.category,
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          const SizedBox(height: 4),
                                          Text(
                                              '₹${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                            product.stock == 0
                                                ? 'OUT OF STOCK'
                                                : 'Stock: ${product.stock}${product.stock <= 5 ? ' ⚠ Low Stock' : ''}',
                                            style: TextStyle(
                                                color: product.stock == 0
                                                    ? Colors.red
                                                    : product.stock <= 5
                                                        ? Colors.orange
                                                        : Colors.black87,
                                                fontWeight: product.stock <= 5
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                          ),
                                        ]),
                                  ),
                                  Column(children: [
                                    TextButton(
                                        onPressed: () => _startEdit(product),
                                        child: const Text('Edit')),
                                    IconButton(
                                        onPressed: () =>
                                            _deleteProduct(product.id),
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red)),
                                  ]),
                                ]),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
