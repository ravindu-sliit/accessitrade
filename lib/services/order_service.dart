import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/order.dart';
import 'package:accessitrade/models/cart_item.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Create order from cart items
  Future<AppOrder> createOrder({
    required List<CartItem> cartItems,
    required String deliveryAddress,
    required String deliveryMethod,
    required double deliveryFee,
    required String paymentMethod,
  }) async {
    if (_userId == null) throw Exception('User not signed in');

    final items = cartItems.map((c) => OrderItem(
      productId: c.productId,
      productName: c.productName,
      price: c.price,
      quantity: c.quantity,
    )).toList();

    final subtotal = cartItems.fold(0.0, (sum, c) => sum + c.subtotal);
    final total = subtotal + deliveryFee;

    final estimatedDelivery = deliveryMethod == 'Express Delivery'
        ? DateTime.now().add(const Duration(days: 3))
        : deliveryMethod == 'Same Day Delivery'
            ? DateTime.now().add(const Duration(hours: 8))
            : DateTime.now().add(const Duration(days: 7));

    final order = AppOrder(
      id: '',
      userId: _userId!,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      deliveryAddress: deliveryAddress,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      estimatedDelivery: estimatedDelivery,
    );

    final ref = await _db.collection('orders').add(order.toFirestore());
    return AppOrder(
      id: ref.id,
      userId: order.userId,
      items: order.items,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,
      deliveryAddress: order.deliveryAddress,
      deliveryMethod: order.deliveryMethod,
      paymentMethod: order.paymentMethod,
      status: order.status,
      createdAt: order.createdAt,
      estimatedDelivery: order.estimatedDelivery,
    );
  }

  // Get user orders
  Stream<List<AppOrder>> getUserOrders() {
    if (_userId == null) return Stream.value([]);
    return _db.collection('orders')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs.map((doc) => AppOrder.fromFirestore(doc)).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Get single order
  Future<AppOrder?> getOrder(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return AppOrder.fromFirestore(doc);
  }
}