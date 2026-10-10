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
        snap.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((product) => product.sellerId != 'seed')
            .toList());
  }

  // Get seller-listed products for the home screen.
  Stream<List<Product>> getFeaturedProducts({int limit = 10}) {
    return _db.collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((product) => product.sellerId != 'seed')
            .toList());
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

}