import 'package:flutter/material.dart';
import 'package:accessitrade/models/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final AppOrder order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(order.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A5C5A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Courier info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE0F2F1), shape: BoxShape.circle),
                    child: const Icon(Icons.local_shipping_outlined,
                        color: Color(0xFF1A5C5A)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.courierName ?? 'DHL Express',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tracking: ${order.trackingNumber ?? 'Pending'}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Call courier button',
                    button: true,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_outlined,
                          color: Color(0xFF1A5C5A), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Timeline',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...List.generate(steps.length, (i) {
                    final step = steps[i];
                    final isDone = i < currentIndex;
                    final isActive = i == currentIndex;
                    final isPending = i > currentIndex;
                    final isLast = i == steps.length - 1;

                    return Semantics(
                      label: '${_stepLabel(step)}: ${isDone ? 'completed' : isActive ? 'current status' : 'pending'}',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline indicator
                          Column(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? const Color(0xFF1A5C5A)
                                      : isActive
                                          ? const Color(0xFF1A5C5A)
                                          : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isDone
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 16)
                                      : isActive
                                          ? Container(
                                              width: 10, height: 10,
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle),
                                            )
                                          : Container(
                                              width: 10, height: 10,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade400,
                                                  shape: BoxShape.circle),
                                            ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2, height: 40,
                                  color: isDone
                                      ? const Color(0xFF1A5C5A)
                                      : Colors.grey.shade200,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _stepLabel(step),
                                    style: TextStyle(
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isPending
                                          ? Colors.grey.shade400
                                          : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  if (isDone || isActive)
                                    Text(
                                      _stepSubtitle(step, order),
                                      style: TextStyle(
                                        color: isActive
                                            ? const Color(0xFF1A5C5A)
                                            : Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    )
                                  else
                                    Text('Pending',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Items',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    'Qty: ${item.quantity} · Rs. ${item.price.toStringAsFixed(0)} each',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rs. ${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A5C5A)),
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Rs. ${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A5C5A),
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Contact courier button',
                    button: true,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A5C5A),
                        side: const BorderSide(
                            color: Color(0xFF1A5C5A), width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Contact Courier',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    label: 'Contact seller button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5C5A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Contact Seller',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _stepLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.confirmed: return 'Payment Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  String _stepSubtitle(OrderStatus status, AppOrder order) {
    final date = _formatDate(order.createdAt);
    switch (status) {
      case OrderStatus.placed: return '$date, ${_formatTime(order.createdAt)}';
      case OrderStatus.confirmed: return '$date, ${_formatTime(order.createdAt.add(const Duration(minutes: 2)))}';
      case OrderStatus.processing: return 'Being prepared for shipment';
      case OrderStatus.shipped:
        return order.trackingNumber != null
            ? 'In transit via ${order.courierName ?? 'courier'} - ${order.trackingNumber}'
            : 'In transit';
      case OrderStatus.outForDelivery: return 'Out for delivery';
      case OrderStatus.delivered: return 'Delivered successfully';
      case OrderStatus.cancelled: return 'Order was cancelled';
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$min $period';
  }
}