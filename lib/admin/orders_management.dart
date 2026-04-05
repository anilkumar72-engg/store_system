import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../services/order_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class OrdersManagementPage extends StatelessWidget {
  const OrdersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OrderService();
    void navigateTo(String route) {
      Navigator.pushReplacementNamed(context, route);
    }

    return Scaffold(
      appBar: const TopBar(title: 'Admin Orders'),
      body: Row(
        children: [
          AppSidebar(selected: AppRoutes.adminOrders, onSelect: navigateTo),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Orders',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder(
                      stream: service.getOrders(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(
                              child: CircularProgressIndicator());
                        final orders = snapshot.data as List? ?? [];
                        if (orders.isEmpty)
                          return const Center(child: Text('No orders yet.'));
                        return ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Card(
                              child: ListTile(
                                title: Text('Order ${order.orderId}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total: ₹${order.total.toStringAsFixed(2)} · ${order.paymentMethod}'),
                                    if ((order.customerName ?? '').isNotEmpty)
                                      Text('Customer: ${order.customerName}'),
                                    if ((order.customerMobile ?? '').isNotEmpty)
                                      Text('Mobile: ${order.customerMobile}'),
                                  ],
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.orderReceipt,
                                        arguments: {'order': order});
                                  },
                                  child: const Text('View Receipt'),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.orderReceipt,
                                      arguments: {'order': order});
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
