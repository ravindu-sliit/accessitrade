import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/order.dart';
import 'package:accessitrade/models/cart_item.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Create order from cart items — also decrements product stock
  Future<AppOrder> createOrder({
    required List<CartItem> cartItems,
    required String deliveryAddress,
    required String deliveryMethod,
    required double deliveryFee,
    required String paymentMethod,
  }) async {
    if (_userId == null) throw Exception('User not signed in');

    // Resolve seller IDs from products so stale cart records cannot hide orders.
    final sellerIdsByProduct = <String, String>{};
    for (final cartItem in cartItems) {
      if (cartItem.productId.isNotEmpty) {
        final product = await _db
            .collection('products')
            .doc(cartItem.productId)
            .get();
        final data = product.data();
        final sellerId = data?['sellerId'] as String?;
        if (sellerId != null && sellerId.isNotEmpty) {
          sellerIdsByProduct[cartItem.productId] = sellerId;
        }
      }
    }

    final items = cartItems.map((c) {
      final sellerId = c.sellerId.isNotEmpty
          ? c.sellerId
          : sellerIdsByProduct[c.productId] ?? '';
      return OrderItem(
        productId: c.productId,
        productName: c.productName,
        price: c.price,
        quantity: c.quantity,
        sellerId: sellerId,
      );
    }).toList();

    final subtotal = cartItems.fold(0.0, (acc, c) => acc + c.subtotal);
    final total = subtotal + deliveryFee;

    // Collect unique seller IDs for this order
    final sellerIds = items
        .map((item) => item.sellerId)
        .toSet()
        .where((id) => id.isNotEmpty)
        .toList();

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
      sellerIds: sellerIds,
    );

    // Use a Firestore batch to atomically:
    // 1. Create the order document
    // 2. Decrement stockQty for each product
    final batch = _db.batch();

    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, order.toFirestore());

    for (final cartItem in cartItems) {
      if (cartItem.productId.isNotEmpty) {
        final productRef = _db.collection('products').doc(cartItem.productId);
        batch.update(productRef, {
          'stockQty': FieldValue.increment(-cartItem.quantity),
        });
      }
    }

    await batch.commit();

    return AppOrder(
      id: orderRef.id,
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
      sellerIds: sellerIds,
    );
  }

  // Get user orders
  Stream<List<AppOrder>> getUserOrders() {
    if (_userId == null) return Stream.value([]);
    return _db
        .collection('orders')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs
              .map((doc) => AppOrder.fromFirestore(doc))
              .toList();
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

  // Update order status (for sellers)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({'status': status.name});
  }

  // Setup courier for an order
  Future<void> setupCourier({
    required String orderId,
    required String courierName,
    required String trackingNumber,
    required DateTime pickupTime,
  }) async {
    await _db.collection('orders').doc(orderId).update({
      'courierName': courierName,
      'trackingNumber': trackingNumber,
      'pickupTime': Timestamp.fromDate(pickupTime),
      'status': OrderStatus.confirmed.name,
    });
  }
}
