import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_routes.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/storage_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductService _productService = ProductService();
  final StorageService _storageService = StorageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _actualPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();

  String _unit = "Piece";
  String _imageUrl = "";
  bool _uploadingImage = false;
  bool _saving = false;
  String? _editingId;

  final List<String> _units = [
    'Kg',
    'Gram',
    'Litre',
    'ml',
    'Piece',
    'Pack',
    'Bottle',
    'Box',
    'Bundle'
  ];

  void _resetForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _categoryController.clear();
      _actualPriceController.clear();
      _sellingPriceController.clear();
      _quantityController.clear();
      _stockController.clear();
      _barcodeController.clear();
      _shortDescriptionController.clear();
      _unit = "Piece";
      _imageUrl = "";
    });
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _uploadingImage = true;
      });
      final url = await _storageService.pickAndUploadImage();
      if (url != null) {
        setState(() {
          _imageUrl = url;
        });
        if (_editingId != null) {
          debugPrint('Firestore imageUrl value: $url');
          await FirebaseFirestore.instance
              .collection('products')
              .doc(_editingId)
              .update({'imageUrl': url});
        }
      }
    } catch (e) {
      debugPrint('Firebase upload exception: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e', style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final actualPrice = double.tryParse(_actualPriceController.text.trim()) ?? 0.0;
    final sellingPrice = double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
    final stock = int.tryParse(_stockController.text.trim());
    final barcode = _barcodeController.text.trim();
    final shortDescription = _shortDescriptionController.text.trim();
    final imageUrl = _imageUrl;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product name is required.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }
    if (category.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Category is required.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }
    if (actualPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid numeric actual price.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }
    if (sellingPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid numeric selling price.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid numeric quantity.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }
    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid numeric stock.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final product = ProductModel(
        id: _editingId ?? '',
        name: name,
        description: shortDescription.isNotEmpty ? shortDescription : '$name details',
        price: sellingPrice,
        stock: stock,
        category: category,
        imageUrl: imageUrl,
        barcode: barcode,
        createdAt: Timestamp.now(),
        actualPrice: actualPrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
        unit: _unit,
        shortDescription: shortDescription,
      );

      if (_editingId != null) {
        await _productService.updateProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully.', style: TextStyle(fontFamily: 'Poppins'))));
      } else {
        await _productService.addProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully.', style: TextStyle(fontFamily: 'Poppins'))));
      }
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e', style: const TextStyle(fontFamily: 'Poppins'))));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _startEdit(ProductModel product) {
    setState(() {
      _editingId = product.id;
      _nameController.text = product.name;
      _categoryController.text = product.category;
      _actualPriceController.text = product.actualPrice.toString();
      _sellingPriceController.text = product.sellingPrice.toString();
      _quantityController.text = product.quantity.toString();
      _stockController.text = product.stock.toString();
      _barcodeController.text = product.barcode;
      _shortDescriptionController.text = product.shortDescription;
      _unit = _units.contains(product.unit) ? product.unit : 'Piece';
      _imageUrl = product.imageUrl;
    });
  }

  Future<void> _deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    if (_editingId == id) _resetForm();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Product deleted.', style: TextStyle(fontFamily: 'Poppins'))));
  }

  @override
  Widget build(BuildContext context) {
    void navigateTo(String route) {
      Navigator.pushReplacementNamed(context, route);
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktopLayout = width >= 1000;

    return Scaffold(
      appBar: const TopBar(title: 'Admin - Product Management'),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          AppSidebar(selected: AppRoutes.adminProducts, onSelect: navigateTo),
          Expanded(
            child: isDesktopLayout
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Responsive Grid (Occupies flex 3)
                      Expanded(
                        flex: 3,
                        child: _buildGridSection(),
                      ),
                      // Right: Form (Occupies 420px width)
                      Container(
                        width: 420,
                        height: double.infinity,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _editingId == null ? 'Add Product' : 'Edit Product',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildFormContent(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildMobileOrTabletLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOrTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingId == null ? 'Add Product' : 'Edit Product',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormContent(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Product List',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 600,
            child: _buildGridSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name & Category
        TextField(
          controller: _nameController,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Product Name',
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _categoryController,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        // Prices (Actual & Selling)
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _actualPriceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Actual Price',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Selling Price',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Qty & Unit
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _units.contains(_unit) ? _unit : 'Piece',
                items: _units.map((u) {
                  return DropdownMenuItem<String>(
                    value: u,
                    child: Text(u, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _unit = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Unit',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Stock & Barcode
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Stock',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _barcodeController,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Description
        TextField(
          controller: _shortDescriptionController,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Short Description',
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        // Premium Upload/Drag-drop container
        _buildUploadContainer(),
        const SizedBox(height: 24),
        // Save & Cancel Row
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _uploadingImage || _saving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _editingId == null ? 'Save Product' : 'Update Product',
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
        if (_editingId != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: _resetForm,
            child: const Text('Cancel Edit', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadContainer() {
    if (_uploadingImage) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );
    }

    if (_imageUrl.isNotEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200, width: 1.5),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF2E7D32)),
                  label: const Text('Change Image', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => setState(() => _imageUrl = ""),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text('Remove', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      painter: DashedBorderPainter(color: Colors.green.shade300),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.green.shade700),
              const SizedBox(height: 8),
              Text(
                'Choose Image',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade800),
              ),
              const SizedBox(height: 2),
              Text(
                'PNG, JPG, WEBP formats accepted',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Inventory',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track and manage supermarket products',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products available.', style: TextStyle(fontFamily: 'Poppins')),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    int count = 2;
                    if (width >= 1200) {
                      count = 4;
                    } else if (width >= 900) {
                      count = 3;
                    } else if (width >= 600) {
                      count = 2;
                    } else {
                      count = 1;
                    }

                    final cardWidth = (width - (count - 1) * 16 - 16) / count;
                    final double ratio = cardWidth / 450;

                    return GridView.builder(
                      padding: const EdgeInsets.only(top: 5, bottom: 20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductGridCard(
                          product: product,
                          onEdit: () => _startEdit(product),
                          onDelete: () => _deleteProduct(product.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGridCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductGridCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<_ProductGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product.actualPrice > widget.product.sellingPrice;
    final discountPercent = hasDiscount
        ? (((widget.product.actualPrice - widget.product.sellingPrice) / widget.product.actualPrice) * 100).round()
        : 0;

    final String quantityStr = widget.product.quantity % 1 == 0
        ? widget.product.quantity.toInt().toString()
        : widget.product.quantity.toStringAsFixed(1);
    final String qtyUnitLabel = "$quantityStr ${widget.product.unit}";

    final lowStock = widget.product.stock <= 5;
    final outOfStock = widget.product.stock == 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _hovered ? -5.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.04),
              blurRadius: _hovered ? 16 : 8,
              offset: Offset(0, _hovered ? 6 : 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: widget.product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.product.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade50,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          alignment: Alignment.center,
                          child: Icon(Icons.image_outlined, size: 50, color: Colors.grey.shade400),
                        ),
                ),
                // Discount Badge overlay
                if (hasDiscount)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Text Details & Actions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFDCEDC8)),
                          ),
                          child: Text(
                            widget.product.category,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF33691E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stock Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: outOfStock
                                ? Colors.red.shade50
                                : lowStock
                                    ? Colors.orange.shade50
                                    : Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: outOfStock
                                  ? Colors.red.shade100
                                  : lowStock
                                      ? Colors.orange.shade100
                                      : Colors.blueGrey.shade100,
                            ),
                          ),
                          child: Text(
                            outOfStock
                                ? 'OUT OF STOCK'
                                : 'Stock: ${widget.product.stock}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: outOfStock
                                  ? Colors.red.shade700
                                  : lowStock
                                      ? Colors.orange.shade800
                                      : Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.product.shortDescription,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Quantity and Unit label
                    Text(
                      qtyUnitLabel,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                    const Spacer(),
                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount)
                              Text(
                                '₹${widget.product.actualPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '₹${widget.product.sellingPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Actions Row (Edit/Delete icons bottom right)
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              color: Colors.blue.shade700,
                              tooltip: 'Edit Product',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: widget.onDelete,
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.red.shade700,
                              tooltip: 'Delete Product',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.dash = 6.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    double distance = 0.0;
    for (final PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
