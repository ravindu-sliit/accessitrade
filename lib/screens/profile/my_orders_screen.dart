import 'package:flutter/material.dart';
import 'package:accessitrade/models/order.dart';
import 'package:accessitrade/services/order_service.dart';
import 'package:accessitrade/screens/profile/order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppOrder> _filterOrders(List<AppOrder> orders, int tabIndex) {
    switch (tabIndex) {
      case 0: return orders;
      case 1: return orders.where((o) =>
        o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
      case 2: return orders.where((o) => o.status == OrderStatus.delivered).toList();
      case 3: return orders.where((o) => o.status == OrderStatus.cancelled).toList();
      default: return orders;
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.confirmed:
      case OrderStatus.processing: return Colors.orange;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery: return Colors.blue;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFFE0F2F1), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A5C5A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('My Orders',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1A5C5A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1A5C5A),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: StreamBuilder<List<AppOrder>>(
        stream: _orderService.getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A5C5A)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allOrders = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: List.generate(4, (tabIndex) {
              final orders = _filterOrders(allOrders, tabIndex);

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        tabIndex == 0 ? 'No orders yet' :
                        tabIndex == 1 ? 'No active orders' :
                        tabIndex == 2 ? 'No completed orders' :
                        'No cancelled orders',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isActive = order.status != OrderStatus.delivered &&
                      order.status != OrderStatus.cancelled;

                  return Semantics(
                    label: 'Order ${order.orderNumber}, ${order.statusLabel}, Rs. ${order.total.toStringAsFixed(0)}',
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order.orderNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A5C5A))),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.statusLabel,
                                  style: TextStyle(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ordered on ${_formatDate(order.createdAt)}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.items.map((i) => i.productName).join(', '),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs. ${order.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Color(0xFF1A5C5A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (isActive) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OrderTrackingScreen(order: order),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? const Color(0xFF1A5C5A)
                                      : Colors.transparent,
                                  foregroundColor: isActive
                                      ? Colors.white
                                      : const Color(0xFF1A5C5A),
                                  side: isActive
                                      ? null
                                      : const BorderSide(color: Color(0xFF1A5C5A)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                  elevation: isActive ? 1 : 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  isActive ? 'Track Order' : 'Reorder',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}