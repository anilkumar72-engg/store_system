import 'package:flutter/material.dart';

class BillingPanel extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  const BillingPanel({super.key, required this.subtotal, required this.tax, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Billing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
            Text('Tax: \$${tax.toStringAsFixed(2)}'),
            const Divider(),
            Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
