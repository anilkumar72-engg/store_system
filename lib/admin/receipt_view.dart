import 'package:flutter/material.dart';
import '../models/order_model.dart';

class ReceiptView extends StatelessWidget {
  final OrderModel order;
  const ReceiptView({super.key, required this.order});

  String _formatPrice(double value) => '₹${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt.toDate();
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manyam Mart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Date: ${date.toString()}',
              style: const TextStyle(color: Colors.black54)),
          const Divider(height: 24),
          const Text('Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...order.items.map((item) {
            final name = item['name'] ?? 'Item';
            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
            final price = (item['unitPrice'] as num?)?.toDouble() ??
                (item['price'] as num?)?.toDouble() ??
                0.0;
            final total = qty * price;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('$name x$qty',
                            style:
                                const TextStyle(fontWeight: FontWeight.w500))),
                    Text(_formatPrice(total),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
            );
          }),
          const SizedBox(height: 12),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal'),
            Text(_formatPrice(order.subtotal))
          ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Tax'), Text(_formatPrice(order.tax))]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_formatPrice(order.total),
                style: const TextStyle(fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Payment Method',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text(order.paymentMethod)
          ]),
        ]),
      ),
    );
  }
}
