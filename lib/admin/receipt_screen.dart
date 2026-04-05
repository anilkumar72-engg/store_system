import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';

class ReceiptScreen extends StatelessWidget {
  final OrderModel order;

  const ReceiptScreen({super.key, required this.order});

  String _formatPrice(double value) => '₹${value.toStringAsFixed(2)}';

  Future<void> _printReceipt(BuildContext context) async {
    final pdf = pw.Document();
    final date = DateTime.now();
    pdf.addPage(pw.Page(build: (context) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Manyam Mart', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Order ID: ${order.orderId}'),
        pw.Text('Date: ${date.toString()}'),
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.Text('Products', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Column(children: order.items.map((item) {
          final qty = item['quantity'];
          final price = (item['price'] as num).toDouble();
          final subtotal = qty * price;
          return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('${item['name']} x$qty'), pw.Text(_formatPrice(subtotal))]);
        }).toList()),
        pw.SizedBox(height: 12),
        pw.Divider(),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Subtotal:'), pw.Text(_formatPrice(order.subtotal))]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Tax:'), pw.Text(_formatPrice(order.tax))]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(_formatPrice(order.total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
        pw.SizedBox(height: 6),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Payment:'), pw.Text(order.paymentMethod)]),
      ]);
    }));

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt.toDate();
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manyam Mart', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Order ID: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Date: $date', style: const TextStyle(color: Colors.black54)),
          const Divider(height: 20),
          const Text('Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...order.items.map((item) {
            final qty = item['quantity'];
            final price = (item['price'] as num).toDouble();
            final subtotal = qty * price;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text('${item['name']} x$qty', style: const TextStyle(fontWeight: FontWeight.w600))),
                Text(_formatPrice(subtotal)),
              ]),
            );
          }).toList(),
          const Spacer(),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal:'), Text(_formatPrice(order.subtotal))]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax:'), Text(_formatPrice(order.tax))]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)), Text(_formatPrice(order.total), style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Payment Method:'), Text(order.paymentMethod)]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _printReceipt(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              child: const Text('Print Receipt'),
            ),
          ),
        ]),
      ),
    );
  }
}
