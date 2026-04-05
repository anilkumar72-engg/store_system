import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}
