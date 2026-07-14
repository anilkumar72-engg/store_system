import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';
import '../models/product_model.dart';

class ProductService {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<ProductModel>> getProducts() {
    return _firestoreService.products.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addProduct(ProductModel product) {
    final map = product.toMap();
    debugPrint('Firestore add Map: $map');
    final doc = _firestoreService.products.doc();
    return doc.set(map);
  }

  Future<void> updateProduct(ProductModel product) {
    final map = product.toMap();
    debugPrint('Firestore update Map: $map');
    return _firestoreService.products.doc(product.id).update(map);
  }

  Future<void> deleteProduct(String id) {
    return _firestoreService.products.doc(id).delete();
  }

  Future<void> seedDefaultProductsIfEmpty() async {
    final snapshot = await _firestoreService.products.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final now = Timestamp.now();
    final sample = [
      {
        'name': 'Bamboo Hand Bag',
        'description': 'Stylish eco hand bag',
        'price': 499.0,
        'stock': 40,
        'category': 'Accessories',
        'barcode': 'BMB001',
        'imageUrl': 'https://images.unsplash.com/photo-1475174710339-2f0f14f3d4f2',
        'createdAt': now,
        'actualPrice': 599.0,
        'sellingPrice': 499.0,
        'quantity': 1.0,
        'unit': 'Piece',
        'shortDescription': 'Stylish eco hand bag',
      },
      {
        'name': 'Bamboo Basket',
        'description': 'Hand-woven bamboo basket',
        'price': 299.0,
        'stock': 50,
        'category': 'Home',
        'barcode': 'BMB003',
        'imageUrl': 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4',
        'createdAt': now,
        'actualPrice': 349.0,
        'sellingPrice': 299.0,
        'quantity': 500.0,
        'unit': 'Gram',
        'shortDescription': 'Hand-woven bamboo basket',
      },
      {
        'name': 'Bamboo Toothbrush',
        'description': 'Eco-friendly bamboo toothbrush',
        'price': 79.0,
        'stock': 150,
        'category': 'Toiletries',
        'barcode': 'BMB002',
        'imageUrl': 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6',
        'createdAt': now,
        'actualPrice': 99.0,
        'sellingPrice': 79.0,
        'quantity': 1.0,
        'unit': 'Piece',
        'shortDescription': 'Eco-friendly bamboo toothbrush',
      },
      {
        'name': 'Bamboo Comb',
        'description': 'Smooth bamboo comb',
        'price': 129.0,
        'stock': 100,
        'category': 'Personal Care',
        'barcode': 'BMB005',
        'imageUrl': 'https://images.unsplash.com/photo-1514826786317-59744f6ad2b4',
        'createdAt': now,
        'actualPrice': 149.0,
        'sellingPrice': 129.0,
        'quantity': 1.0,
        'unit': 'Piece',
        'shortDescription': 'Smooth bamboo comb',
      },
      {
        'name': 'Bamboo Water Bottle',
        'description': 'Reusable bamboo flask',
        'price': 249.0,
        'stock': 80,
        'category': 'Kitchen',
        'barcode': 'BMB004',
        'imageUrl': 'https://images.unsplash.com/photo-1508747703725-7197bfe8b44c',
        'createdAt': now,
        'actualPrice': 299.0,
        'sellingPrice': 249.0,
        'quantity': 750.0,
        'unit': 'ml',
        'shortDescription': 'Reusable bamboo flask',
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final product in sample) {
      final doc = _firestoreService.products.doc();
      batch.set(doc, product);
    }
    await batch.commit();
  }
}
