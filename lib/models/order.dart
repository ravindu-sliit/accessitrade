import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { placed, confirmed, processing, shipped, outForDelivery, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String sellerId;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.sellerId,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      sellerId: data['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId,
    };
  }
}

class AppOrder {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final OrderStatus status;
  final String? trackingNumber;
  final String? courierName;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  // List of unique seller IDs in this order (for seller querying)
  final List<String> sellerIds;

  AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.status,
    this.trackingNumber,
    this.courierName,
    required this.createdAt,
    this.estimatedDelivery,
    this.sellerIds = const [],
  });

  String get orderNumber => '#AM-${createdAt.year}-${id.substring(0, 4).toUpperCase()}';

  String get statusLabel {
    switch (status) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  factory AppOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      deliveryMethod: data['deliveryMethod'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.placed,
      ),
      trackingNumber: data['trackingNumber'],
      courierName: data['courierName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDelivery: (data['estimatedDelivery'] as Timestamp?)?.toDate(),
      sellerIds: List<String>.from(data['sellerIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'trackingNumber': trackingNumber,
      'courierName': courierName,
      'createdAt': FieldValue.serverTimestamp(),
      'estimatedDelivery': estimatedDelivery != null
          ? Timestamp.fromDate(estimatedDelivery!)
          : null,
      'sellerIds': sellerIds,
    };
  }
}
