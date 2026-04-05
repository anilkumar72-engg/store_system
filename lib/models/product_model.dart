import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final String barcode;
  final Timestamp createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.barcode,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? 'General',
      imageUrl: map['imageUrl'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'createdAt': createdAt,
    };
  }
}
