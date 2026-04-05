import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartPanel extends StatelessWidget {
  final List<CartItem> cart;
  final void Function(CartItem) onIncrease;
  final void Function(CartItem) onDecrease;
  final void Function(CartItem) onRemove;

  const CartPanel({super.key, required this.cart, required this.onIncrease, required this.onDecrease, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shopping_cart_outlined, size: 52, color: Colors.grey),
                SizedBox(height: 10),
                Text('Cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Scan barcode or add products', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cart.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = cart[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    IconButton(onPressed: () => onRemove(item), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                    Row(
                      children: [
                        IconButton(onPressed: () => onDecrease(item), icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF2E7D32))),
                        Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                        IconButton(onPressed: () => onIncrease(item), icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2E7D32))),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text('Total: ₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}

