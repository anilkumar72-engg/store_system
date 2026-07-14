import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final Function(ProductModel) addToCart;
  final String selectedCategory;
  final String searchQuery;
  final ValueChanged<String> onCategorySelected;

  const ProductGrid({
    super.key,
    required this.addToCart,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onCategorySelected,
  });

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4; // Large Desktop
    if (width >= 900) return 3;  // Laptop / normal screen
    if (width >= 600) return 2;  // Tablet
    return 1;                    // Mobile
  }

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final categories = ['All', 'Handbags', 'Food', 'Personal Care', 'Home Decor'];

    return StreamBuilder<List<ProductModel>>(
      stream: productService.getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
        }

        var products = snapshot.data!;
        if (selectedCategory != 'All') {
          products = products.where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
        }
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          products = products.where((p) => p.name.toLowerCase().contains(query) || p.category.toLowerCase().contains(query) || p.barcode.toLowerCase().contains(query)).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final selected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(category, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        selected: selected,
                        selectedColor: const Color(0xFF2E7D32),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: selected ? Colors.transparent : Colors.grey.shade300),
                        onSelected: (_) => onCategorySelected(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.search_off, size: 52, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No products found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          SizedBox(height: 4),
                          Text('Try another keyword or category', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                        ],
                      ),
                    )
                  : LayoutBuilder(builder: (context, constraints) {
                      final count = _getCrossAxisCount(constraints.maxWidth);
                      final cardWidth = (constraints.maxWidth - (count - 1) * 10 - 16) / count;
                      // Bounded card height is 450px
                      final double ratio = cardWidth / 450;

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: ratio,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: products[index],
                            onAdd: () => addToCart(products[index]),
                          );
                        },
                      );
                    }),
            ),
          ],
        );
      },
    );
  }
}
