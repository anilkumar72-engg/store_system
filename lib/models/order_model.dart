import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final Timestamp createdAt;
  final String? customerName;
  final String? customerMobile;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.customerName,
    this.customerMobile,
  });
}
