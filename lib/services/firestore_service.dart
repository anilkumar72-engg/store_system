import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get products => _db.collection('products');
  CollectionReference<Map<String, dynamic>> get orders => _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get customers => _db.collection('customers');
  CollectionReference<Map<String, dynamic>> get inventory => _db.collection('inventory');
  CollectionReference<Map<String, dynamic>> get users => _db.collection('users');
}
