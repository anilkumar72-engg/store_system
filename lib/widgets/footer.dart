import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Opacity(
      opacity: 0.7,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Designed & Developed by Anil Kumar Budda',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Support: anilkumarbudha72@gmail.com',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '© 2026 Manyam Mart. All Rights Reserved.  |  Version 1.0.0',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Designed & Developed by Anil Kumar Budda',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Support: anilkumarbudha72@gmail.com  |  © 2026 Manyam Mart. All Rights Reserved.  |  Version 1.0.0',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
