import 'package:flutter/material.dart';
import 'dart:async';

class StoreHeader extends StatefulWidget {
  final VoidCallback? onAdmin;
  final VoidCallback? onLogout;

  const StoreHeader({super.key, this.onAdmin, this.onLogout});

  @override
  State<StoreHeader> createState() => _StoreHeaderState();
}

class _StoreHeaderState extends State<StoreHeader> {
  late Timer _timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(11),
                child: const Icon(Icons.storefront_rounded, color: Color(0xFF2E7D32), size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Manyam Mart POS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  SizedBox(height: 2),
                  Text('Point of Sale', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(date, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
                ],
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: widget.onAdmin,
                icon: const Icon(Icons.admin_panel_settings, size: 18, color: Colors.white),
                label: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF616161),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
