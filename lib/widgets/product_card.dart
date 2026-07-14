import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onAdd;

  const ProductCard({super.key, required this.product, required this.onAdd});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product.actualPrice > widget.product.sellingPrice;
    final discountPercent = hasDiscount
        ? (((widget.product.actualPrice - widget.product.sellingPrice) / widget.product.actualPrice) * 100).round()
        : 0;

    // Formatting Quantity and Unit: e.g. "30 Gram", "500 ml", "1 Kg"
    final String quantityStr = widget.product.quantity % 1 == 0
        ? widget.product.quantity.toInt().toString()
        : widget.product.quantity.toStringAsFixed(1);
    final String qtyUnitLabel = "$quantityStr ${widget.product.unit}";

    final lowStock = widget.product.stock <= 5;
    final outOfStock = widget.product.stock == 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.12 : 0.04),
              blurRadius: _hover ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Fixed 200px Height Image with Center Crop
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
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                                SizedBox(height: 4),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
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
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for Category and Stock Chips
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
                    // Product Name
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
                    // Short Description (small grey text)
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
                    // Price and Action section at bottom
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price text
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
                        // Add Button bottom right
                        ElevatedButton(
                          onPressed: outOfStock ? null : widget.onAdd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: outOfStock
                                ? Colors.grey
                                : const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            minimumSize: const Size(68, 38),
                            elevation: _hover ? 3 : 1,
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
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
