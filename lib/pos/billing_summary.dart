import 'package:flutter/material.dart';

class BillingSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;

  const BillingSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _summaryRow('Subtotal', subtotal),
          const SizedBox(height: 6),
          _summaryRow('Tax (5%)', tax),
          const Divider(height: 24, thickness: 1.2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text('₹${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
