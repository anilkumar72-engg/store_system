import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../core/constants/app_routes.dart';
import '../services/order_service.dart';
import '../services/product_seed.dart';
import '../models/order_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/footer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selected = AppRoutes.admin;
  final OrderService _orderService = OrderService();

  void navigate(String route) {
    setState(() {
      selected = route;
    });
    Navigator.of(context).pushReplacementNamed(route);
  }

  List<DateTime> _lastSevenDays() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - index));
      return day;
    });
  }

  Map<String, double> _salesByDate(List<OrderModel> orders) {
    final map = <String, double>{};
    for (final order in orders) {
      final dt = order.createdAt.toDate();
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + order.total;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService().getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final role = snapshot.data ?? 'Cashier';
        if (role != 'Admin') {
          return Scaffold(
            appBar: const TopBar(title: 'Unauthorized'),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Access denied', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Only admin users can access this screen.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.pos),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    child: const Text('Go to POS'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: const TopBar(title: 'Admin Dashboard'),
          body: Row(
            children: [
              AppSidebar(selected: selected, onSelect: navigate),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<List<OrderModel>>(
                    stream: _orderService.getOrders(),
                    builder: (context, snapshot) {
                      final orders = snapshot.data ?? [];
                      final today = DateTime.now();
                      final startOfToday = DateTime(today.year, today.month, today.day);
                      final ordersToday = orders.where((o) {
                        final d = o.createdAt.toDate();
                        return d.year == startOfToday.year && d.month == startOfToday.month && d.day == startOfToday.day;
                      }).toList();
                      final todaySales = ordersToday.fold<double>(0, (sum, order) => sum + order.total);
                      final todayProductsSold = ordersToday.fold<int>(0, (sum, order) {
                        final count = order.items.fold<int>(0, (itemSum, i) => itemSum + (i['quantity'] as int));
                        return sum + count;
                      });
                      final averageOrder = ordersToday.isEmpty ? 0.0 : todaySales / ordersToday.length;

                      final weekDays = _lastSevenDays();
                      final salesMap = _salesByDate(orders);
                      final spots = <FlSpot>[];
                      for (var i = 0; i < weekDays.length; i++) {
                        final day = weekDays[i];
                        final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                        final value = salesMap[key] ?? 0;
                        spots.add(FlSpot(i.toDouble(), value));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Admin Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                            onPressed: () async {
                              await ProductSeeder.seedProducts();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded bamboo products')));
                            },
                            child: const Text('Seed Bamboo Products'),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              int crossAxisCount = 4;
                              double childAspectRatio = 3.0;
                              if (width < 600) {
                                crossAxisCount = 1;
                                childAspectRatio = 4.5;
                              } else if (width < 1000) {
                                crossAxisCount = 2;
                                childAspectRatio = 3.5;
                              }

                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: childAspectRatio,
                                children: [
                                  _metricCard('Today Sales', '₹${todaySales.toStringAsFixed(2)}', Icons.attach_money),
                                  _metricCard('Orders Today', '${ordersToday.length}', Icons.shopping_cart),
                                  _metricCard('Products Sold', '$todayProductsSold', Icons.inventory_2),
                                  _metricCard('Average Order', '₹${averageOrder.toStringAsFixed(2)}', Icons.trending_up),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sales Trend (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: LineChart(
                                        LineChartData(
                                          minX: 0,
                                          maxX: 6,
                                          minY: 0,
                                          maxY: spots.isEmpty ? 100 : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity),
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 32,
                                                getTitlesWidget: (value, meta) {
                                                  final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                                  final index = value.toInt();
                                                  if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                                                  return Text(labels[index], style: const TextStyle(fontSize: 11, color: Colors.black87));
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          ),
                                          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1000, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1)),
                                          borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Colors.grey), left: BorderSide(color: Colors.grey), right: BorderSide(color: Colors.transparent), top: BorderSide(color: Colors.transparent))),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: spots,
                                              isCurved: true,
                                              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
                                              barWidth: 3,
                                              dotData: FlDotData(show: true),
                                              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF2E7D32).withValues(alpha: 0.25), Colors.transparent])),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Footer(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFF2E7D32), child: Icon(icon, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontFamily: 'Poppins', fontSize: 12), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

