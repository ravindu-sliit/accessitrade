import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/product.dart';
import 'package:accessitrade/models/order.dart';

class SellerService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _sellerId => _auth.currentUser?.uid;
  String? get currentSellerId => _auth.currentUser?.uid;

  // Stream seller's own products
  Stream<List<Product>> getMyProducts() {
    if (_sellerId == null) return Stream.value([]);
    return _db
        .collection('products')
        .where('sellerId', isEqualTo: _sellerId)
        .snapshots()
        .map((snap) {
          final products = snap.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return products;
        });
  }

  // Stream orders for seller's products
  Stream<List<AppOrder>> getMyOrders() {
    if (_sellerId == null) return Stream.value([]);
    return _db
        .collection('orders')
        .where('sellerIds', arrayContains: _sellerId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((doc) => AppOrder.fromFirestore(doc))
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Add a new product listing
  Future<String> addProduct({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required String category,
    required String altText,
    required int stockQty,
    Map<String, String> specifications = const {},
    String? imageUrl,
  }) async {
    if (_sellerId == null) throw Exception('Not signed in');

    final user = _auth.currentUser;
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'sellerId': _sellerId,
      'sellerName': user?.displayName ?? 'Seller',
      'altText': altText,
      'imageUrls': imageUrl != null ? [imageUrl] : [],
      'rating': 0.0,
      'reviewCount': 0,
      'stockQty': stockQty,
      'isVerified': false,
      'specifications': specifications,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection('products').add(data);
    return ref.id;
  }

  // Update product stock
  Future<void> updateStock(String productId, int newQty) async {
    await _db.collection('products').doc(productId).update({
      'stockQty': newQty,
    });
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // Get seller stats
  Future<Map<String, dynamic>> getStats() async {
    if (_sellerId == null) return {};
    final products = await _db
        .collection('products')
        .where('sellerId', isEqualTo: _sellerId)
        .get();
    return {
      'productCount': products.docs.length,
      'totalStock': products.docs.fold(
        0,
        (acc, doc) => acc + ((doc.data()['stockQty'] ?? 0) as int),
      ),
    };
  }
}
