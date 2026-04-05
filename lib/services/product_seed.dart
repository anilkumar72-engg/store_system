import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSeeder {
  static final List<Map<String, dynamic>> _products = [
    {'name': 'Bamboo Hand Bag', 'category': 'Accessories', 'price': 499.0, 'stock': 40, 'barcode': 'BMB001', 'imageUrl': 'https://images.unsplash.com/photo-1475174710339-2f0f14f3d4f2'},
    {'name': 'Bamboo Toothbrush', 'category': 'Toiletries', 'price': 79.0, 'stock': 150, 'barcode': 'BMB002', 'imageUrl': 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6'},
    {'name': 'Bamboo Basket', 'category': 'Home', 'price': 299.0, 'stock': 50, 'barcode': 'BMB003', 'imageUrl': 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4'},
    {'name': 'Bamboo Water Bottle', 'category': 'Kitchen', 'price': 249.0, 'stock': 80, 'barcode': 'BMB004', 'imageUrl': 'https://images.unsplash.com/photo-1508747703725-7197bfe8b44c'},
    {'name': 'Bamboo Comb', 'category': 'Personal Care', 'price': 129.0, 'stock': 100, 'barcode': 'BMB005', 'imageUrl': 'https://images.unsplash.com/photo-1514826786317-59744f6ad2b4'},
    {'name': 'Bamboo Plate', 'category': 'Kitchen', 'price': 199.0, 'stock': 70, 'barcode': 'BMB006', 'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836'},
    {'name': 'Bamboo Spoon', 'category': 'Kitchen', 'price': 59.0, 'stock': 120, 'barcode': 'BMB007', 'imageUrl': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'},
    {'name': 'Bamboo Lamp', 'category': 'Lighting', 'price': 999.0, 'stock': 35, 'barcode': 'BMB008', 'imageUrl': 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4'},
    {'name': 'Bamboo Chair', 'category': 'Furniture', 'price': 3499.0, 'stock': 20, 'barcode': 'BMB009', 'imageUrl': 'https://images.unsplash.com/photo-1493666438817-866a91353ca9'},
    {'name': 'Bamboo Storage Box', 'category': 'Storage', 'price': 799.0, 'stock': 60, 'barcode': 'BMB010', 'imageUrl': 'https://images.unsplash.com/photo-1524646431313-6b5b9f9683e2'},
    {'name': 'Bamboo Tea Cup', 'category': 'Kitchen', 'price': 169.0, 'stock': 90, 'barcode': 'BMB011', 'imageUrl': 'https://images.unsplash.com/photo-1523906630133-f6934a1abf2f'},
    {'name': 'Bamboo Pen Holder', 'category': 'Office', 'price': 249.0, 'stock': 65, 'barcode': 'BMB012', 'imageUrl': 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6'},
    {'name': 'Bamboo Tray', 'category': 'Kitchen', 'price': 279.0, 'stock': 55, 'barcode': 'BMB013', 'imageUrl': 'https://images.unsplash.com/photo-1491553895911-0055eca6402d'},
    {'name': 'Bamboo Basket Large', 'category': 'Storage', 'price': 1099.0, 'stock': 30, 'barcode': 'BMB014', 'imageUrl': 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4'},
    {'name': 'Bamboo Hair Brush', 'category': 'Personal Care', 'price': 189.0, 'stock': 85, 'barcode': 'BMB015', 'imageUrl': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'},
  ];

  static Future<void> seedProducts() async {
    final collection = FirebaseFirestore.instance.collection('products');
    final snapshot = await collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    for (final product in _products) {
      await collection.add(product);
    }
  }
}
