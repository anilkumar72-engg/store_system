import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const AppSidebar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1B5E20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 110,
            alignment: Alignment.center,
            color: const Color(0xFF2E7D32),
            child: const Text('Manyam Mart', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          _buildItem(context, 'Dashboard', '/admin', selected == '/admin', Icons.dashboard),
          _buildItem(context, 'Products', '/admin/products', selected == '/admin/products', Icons.inventory_2),
          _buildItem(context, 'Orders', '/admin/orders', selected == '/admin/orders', Icons.receipt_long),
          _buildItem(context, 'POS', '/pos', selected == '/pos', Icons.point_of_sale),
          _buildItem(context, 'Store', '/store', selected == '/store', Icons.store),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String route, bool active, IconData icon) {
    return Material(
      color: active ? Colors.green.shade700 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: active ? Colors.white : Colors.white70),
        minLeadingWidth: 0,
        title: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        onTap: () => onSelect(route),
      ),
    );
  }
}
