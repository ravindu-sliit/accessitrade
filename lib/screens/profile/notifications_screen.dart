import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    {'icon': 'shipping', 'title': 'Order Shipped!', 'body': 'Your package #AM-2024-0847 is on its way via DHL.', 'time': 'Today, 2:40 PM', 'unread': true},
    {'icon': 'price', 'title': 'Price Drop Alert', 'body': 'The Ergonomic Walker Frame in your wishlist dropped by Rs. 1,500.', 'time': 'Yesterday, 10:15 AM', 'unread': true},
    {'icon': 'review', 'title': 'New Review Reply', 'body': 'Kumari, the seller replied to your review on Braille Kit.', 'time': '2 days ago', 'unread': false},
    {'icon': 'verified', 'title': 'Account Verified', 'body': 'Your accessibility profile has been reviewed and verified.', 'time': '4 days ago', 'unread': false},
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'shipping': return Icons.local_shipping_outlined;
      case 'price': return Icons.sell_outlined;
      case 'review': return Icons.chat_bubble_outline;
      default: return Icons.check_circle_outline;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'shipping': return const Color(0xFF1A5C5A);
      case 'price': return Colors.orange;
      case 'review': return Colors.blue;
      default: return Colors.green;
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
        title: const Text('Notification', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF1A5C5A), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._notifications.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: n['unread'] == true ? const Color(0xFF1A5C5A) : Colors.grey.shade200,
                width: n['unread'] == true ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getIconColor(n['icon'] as String).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(n['icon'] as String), color: _getIconColor(n['icon'] as String), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(n['body'] as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(n['time'] as String, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                ),
                if (n['unread'] == true)
                  Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFF1A5C5A), shape: BoxShape.circle),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}