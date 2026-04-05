import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference<Map<String, dynamic>> _orders = FirebaseFirestore.instance.collection('orders');
  final CollectionReference<Map<String, dynamic>> _products = FirebaseFirestore.instance.collection('products');

  Future<void> createOrder(OrderModel order, List<Map<String, dynamic>> stockUpdates) async {
    final batch = FirebaseFirestore.instance.batch();
    final orderDoc = _orders.doc(order.orderId);
    final orderMap = {
      'orderId': order.orderId,
      'items': order.items,
      'subtotal': order.subtotal,
      'tax': order.tax,
      'total': order.total,
      'paymentMethod': order.paymentMethod,
      'customerName': order.customerName ?? '',
      'customerMobile': order.customerMobile ?? '',
      'createdAt': order.createdAt,
    };
    batch.set(orderDoc, orderMap);

    for (var update in stockUpdates) {
      final productId = update['id'] as String;
      final quantity = update['quantity'] as int;
      final productDoc = await _products.doc(productId).get();
      final currentStock = (productDoc.data()?['stock'] as num?)?.toInt() ?? 0;
      final newStock = (currentStock - quantity) < 0 ? 0 : (currentStock - quantity);
      batch.update(_products.doc(productId), {'stock': newStock});
    }

    await batch.commit();
  }

  Stream<List<OrderModel>> getOrders() {
    return _orders.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel(
          orderId: data['orderId'] as String? ?? doc.id,
          items: List<Map<String, dynamic>>.from(data['items'] as List<dynamic>? ?? []),
          subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
          tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
          total: (data['total'] as num?)?.toDouble() ?? 0.0,
          paymentMethod: data['paymentMethod'] as String? ?? 'Cash',
          createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
          customerName: (data['customerName'] as String?)?.isEmpty ?? true ? null : data['customerName'] as String?,
          customerMobile: (data['customerMobile'] as String?)?.isEmpty ?? true ? null : data['customerMobile'] as String?,
        );
      }).toList();
    });
  }
}
