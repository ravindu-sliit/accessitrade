import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/cart_item.dart';
import 'package:accessitrade/models/product.dart';

class CartService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference? get _cartRef {
    if (_userId == null) return null;
    return _db.collection('users').doc(_userId).collection('cart');
  }

  // Stream cart items
  Stream<List<CartItem>> getCartItems() {
    if (_cartRef == null) return Stream.value([]);
    return _cartRef!.snapshots().map((snap) =>
        snap.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  // Add product to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_cartRef == null) return;

    // Check if already in cart
    final existing = await _cartRef!
        .where('productId', isEqualTo: product.id)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Increment quantity
      final doc = existing.docs.first;
      final currentQty = (doc.data() as Map)['quantity'] ?? 1;
      await doc.reference.update({'quantity': currentQty + quantity});
    } else {
      // Add new item
      await _cartRef!.add({
        'productId': product.id,
        'productName': product.name,
        'price': product.price,
        'quantity': quantity,
        'imageUrl': product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
        'sellerName': product.sellerName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Remove from cart
  Future<void> removeFromCart(String cartItemId) async {
    await _cartRef?.doc(cartItemId).delete();
  }

  // Update quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await _cartRef?.doc(cartItemId).update({'quantity': quantity});
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_cartRef == null) return;
    final snap = await _cartRef!.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Get cart count
  Stream<int> getCartCount() {
    if (_cartRef == null) return Stream.value(0);
    return _cartRef!.snapshots().map((snap) => snap.docs.length);
  }
}