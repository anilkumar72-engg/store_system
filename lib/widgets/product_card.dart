import 'package:flutter/material.dart';
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(_hover ? 0.18 : 0.06),
                blurRadius: _hover ? 16 : 8,
                offset: const Offset(0, 4)),
          ],
        ),
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 180,
                color: Colors.grey.shade100,
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.product.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image,
                            size: 50, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.product.category,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF777777))),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.stock == 0
                        ? 'OUT OF STOCK'
                        : 'Stock: ${widget.product.stock} ${widget.product.stock <= 5 ? '⚠ Low Stock' : ''}',
                    style: TextStyle(
                        fontSize: 12,
                        color: widget.product.stock == 0
                            ? Colors.red
                            : widget.product.stock <= 5
                                ? Colors.orange
                                : Colors.grey.shade700,
                        fontWeight: widget.product.stock <= 5
                            ? FontWeight.w600
                            : FontWeight.normal),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('₹${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF2E7D32))),
                      const Spacer(),
                      if (widget.product.stock == 0)
                        const Text('OUT OF STOCK',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      if (widget.product.stock > 0 && widget.product.stock <= 5)
                        const Text('⚠ Low Stock',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed:
                            widget.product.stock > 0 ? widget.onAdd : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.product.stock > 0
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(58, 34),
                        ),
                        child: const Text('Add',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
