import 'package:flutter/material.dart';

class CartWidget extends StatelessWidget {
  final Map<String, int> items;

  const CartWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...items.entries.map((e) => Text('${e.key}: ${e.value}')),
          ],
        ),
      ),
    );
  }
}
