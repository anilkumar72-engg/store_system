import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price; // Keeps backward compatibility (equals sellingPrice)
  final int stock;
  final String category;
  final String imageUrl;
  final String barcode;
  final Timestamp createdAt;

  // New fields
  final double actualPrice;
  final double sellingPrice;
  final double quantity;
  final String unit;
  final String shortDescription;

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
    required this.actualPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.unit,
    required this.shortDescription,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    final double sPrice = (map['sellingPrice'] as num?)?.toDouble() ?? (map['price'] as num?)?.toDouble() ?? 0.0;
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed',
      description: map['description'] as String? ?? '',
      price: sPrice,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? 'General',
      imageUrl: map['imageUrl'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      actualPrice: (map['actualPrice'] as num?)?.toDouble() ?? (map['price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: sPrice,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'Piece',
      shortDescription: map['shortDescription'] as String? ?? map['description'] as String? ?? '',
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
      'actualPrice': actualPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'unit': unit,
      'shortDescription': shortDescription,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    String? barcode,
    Timestamp? createdAt,
    double? actualPrice,
    double? sellingPrice,
    double? quantity,
    String? unit,
    String? shortDescription,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      actualPrice: actualPrice ?? this.actualPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      shortDescription: shortDescription ?? this.shortDescription,
    );
  }
}
