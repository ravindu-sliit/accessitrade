import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accessitrade/models/product.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'products';

  // Stream all products
  Stream<List<Product>> getProducts({String? category}) {
    Query query = _db.collection(_collection)
        .orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Get featured products for home screen
  Stream<List<Product>> getFeaturedProducts({int limit = 10}) {
    return _db.collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Get single product
  Future<Product?> getProduct(String productId) async {
    final doc = await _db.collection(_collection).doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  // Search products
  Stream<List<Product>> searchProducts(String query) {
    final lower = query.toLowerCase();
    return _db.collection(_collection)
        .orderBy('name')
        .startAt([lower])
        .endAt(['$lower\uf8ff'])
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Add a product (for sellers)
  Future<String> addProduct(Product product) async {
    final doc = await _db.collection(_collection).add(product.toFirestore());
    return doc.id;
  }

  // Seed sample products if none exist
  Future<void> seedSampleProducts() async {
    final snap = await _db.collection(_collection).limit(1).get();
    if (snap.docs.isNotEmpty) return; // already seeded

    final samples = [
      {
        'name': 'Ergonomic Walker Frame',
        'description': 'Lightweight aluminium walker with ergonomic hand grips and easy-fold mechanism. Suitable for indoor and outdoor use.',
        'price': 18500.0,
        'originalPrice': 22000.0,
        'category': 'Mobility Aids',
        'sellerId': 'seed',
        'sellerName': 'MobilityPlus SL',
        'altText': 'Silver aluminium walker frame with four legs and padded hand grips',
        'imageUrls': [],
        'rating': 4.8,
        'reviewCount': 24,
        'stockQty': 15,
        'isVerified': true,
        'specifications': {
          'Material': 'Aluminium Alloy',
          'Weight': '2.8 kg',
          'Max Load': '120 kg',
          'Adjustable Height': 'Yes',
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Braille Learning Kit',
        'description': 'Complete braille learning set with slate, stylus, alphabet cards and practice workbook. Suitable for beginners.',
        'price': 6200.0,
        'originalPrice': null,
        'category': 'Vision Aids',
        'sellerId': 'seed',
        'sellerName': 'AccessAbility Store',
        'altText': 'Wooden braille learning kit box open showing slate, stylus and alphabet reference cards',
        'imageUrls': [],
        'rating': 4.9,
        'reviewCount': 11,
        'stockQty': 8,
        'isVerified': true,
        'specifications': {
          'Includes': 'Slate, Stylus, Cards, Workbook',
          'Level': 'Beginner',
          'Language': 'Sinhala & English',
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Foldable Wheelchair',
        'description': 'Ultra-lightweight compact steel wheelchair with ergonomic armrests and swing-away leg rests.',
        'price': 45000.0,
        'originalPrice': 52000.0,
        'category': 'Mobility Aids',
        'sellerId': 'seed',
        'sellerName': 'MediCare Solutions',
        'altText': 'Black foldable wheelchair with padded seat and swing-away footrests',
        'imageUrls': [],
        'rating': 4.2,
        'reviewCount': 128,
        'stockQty': 3,
        'isVerified': true,
        'specifications': {
          'Size': 'Standard Adult (18 inch seat)',
          'Material': 'Alloy Steel & Breathable Mesh',
          'Weight': '11.5 kg',
          'Features': 'Foldable backrest, Dual brakes',
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tactile Sensory Ball',
        'description': 'Soft rubber ball with raised bumps and ridges for sensory stimulation. Safe for all ages.',
        'price': 850.0,
        'originalPrice': null,
        'category': 'Sensory Aids',
        'sellerId': 'seed',
        'sellerName': "Sanduni's Crafts",
        'altText': 'Yellow rubber ball with raised tactile bumps covering the entire surface',
        'imageUrls': [],
        'rating': 4.5,
        'reviewCount': 23,
        'stockQty': 50,
        'isVerified': false,
        'specifications': {
          'Material': 'Non-toxic rubber',
          'Diameter': '8 cm',
          'Safe For': 'Ages 3+',
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Non-Slip Grip Cutlery Set',
        'description': 'Ergonomic cutlery set with wide foam handles for easy gripping. Dishwasher safe.',
        'price': 2500.0,
        'originalPrice': null,
        'category': 'Daily Living Aids',
        'sellerId': 'seed',
        'sellerName': 'EasyLiving Lanka',
        'altText': 'Set of four pieces of cutlery with thick foam grip handles in blue',
        'imageUrls': [],
        'rating': 4.3,
        'reviewCount': 17,
        'stockQty': 20,
        'isVerified': true,
        'specifications': {
          'Includes': 'Fork, Knife, Spoon, Teaspoon',
          'Handle': 'Foam grip',
          'Dishwasher Safe': 'Yes',
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _db.batch();
    for (final product in samples) {
      final ref = _db.collection(_collection).doc();
      batch.set(ref, product);
    }
    await batch.commit();
  }
}