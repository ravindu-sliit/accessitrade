import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String sellerId;
  final String sellerName;
  final String altText;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final int stockQty;
  final bool isVerified;
  final Map<String, String> specifications;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.altText,
    this.imageUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockQty = 0,
    this.isVerified = false,
    this.specifications = const {},
    required this.createdAt,
  });

  bool get inStock => stockQty > 0;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: data['originalPrice']?.toDouble(),
      category: data['category'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      altText: data['altText'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stockQty: data['stockQty'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      specifications: Map<String, String>.from(data['specifications'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'altText': altText,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockQty': stockQty,
      'isVerified': isVerified,
      'specifications': specifications,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}