import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Manyam Mart', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Manyam Mart POS', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
            SizedBox(height: 6),
            Text('Version 1.0.0', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
            SizedBox(height: 12),
            Text('Designed & Developed by', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
            Text('Anil Kumar Budda', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87)),
            SizedBox(height: 12),
            Text('Support', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
            Text('anilkumarbudha72@gmail.com', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF2E7D32))),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Text('Powered by Flutter & Firebase', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Profile / Settings',
          onSelected: (value) {
            if (value == 'about') {
              _showAboutDialog(context);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'about',
              child: Text('About', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}
