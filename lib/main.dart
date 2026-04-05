import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'core/constants/app_routes.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StoreSystemApp());
}

class StoreSystemApp extends StatelessWidget {
  const StoreSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manyam Mart',
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
