import 'package:flutter/material.dart';
import '../../admin/admin_dashboard.dart';
import '../../admin/product_management.dart';
import '../../admin/orders_management.dart';
import '../../auth/login_screen.dart';
import '../../models/order_model.dart';
import '../../pos/pos_screen.dart';
import '../../screens/receipt_view.dart';
import '../../store/store_home.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case AppRoutes.adminProducts:
        return MaterialPageRoute(builder: (_) => const ProductManagementPage());
      case AppRoutes.adminOrders:
        return MaterialPageRoute(builder: (_) => const OrdersManagementPage());
      case AppRoutes.orderReceipt:
        final orderArg = settings.arguments as Map<String, dynamic>?;
        if (orderArg == null || orderArg['order'] == null) {
          return MaterialPageRoute(
              builder: (_) => const OrdersManagementPage());
        }
        return MaterialPageRoute(
            builder: (_) => ReceiptView(order: orderArg['order'] as OrderModel));
      case AppRoutes.pos:
        return MaterialPageRoute(builder: (_) => const PosScreen());
      case AppRoutes.store:
      default:
        return MaterialPageRoute(builder: (_) => const StoreHomePage());
    }
  }
}
