import 'package:flutter/material.dart';
import 'package:accessitrade/models/order.dart';
import 'package:accessitrade/services/seller_service.dart';
import 'package:accessitrade/services/order_service.dart';
import 'package:accessitrade/services/user_service.dart';
import 'package:accessitrade/services/document_download_stub.dart'
    if (dart.library.html) 'package:accessitrade/services/document_download_web.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerService = SellerService();
    return Scaffold(
      appBar: AppBar(title: const Text('Active Orders')),
      body: StreamBuilder<List<AppOrder>>(
        stream: sellerService.getMyOrders(),
        builder: (context, snapshot) {
          final orders = (snapshot.data ?? [])
              .where(
                (order) =>
                    order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled,
              )
              .toList();
          if (orders.isEmpty) {
            return const Center(child: Text('No orders in processing'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order.items
                  .where(
                    (item) => item.sellerId == sellerService.currentSellerId,
                  )
                  .toList();
              return _ActiveOrderCard(
                order: order,
                items: items,
                onDownloadAddress: () => _downloadAddress(context, order),
                onSetupCourier: () => _showCourierDialog(context, order),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCourierDialog(BuildContext context, AppOrder order) async {
    final trackingController = TextEditingController();
    const courierOptions = [
      'DHL Express',
      'Domex',
      'PickMe Flash',
      'Koombiyo Delivery',
    ];
    var selectedCourier = courierOptions.first;
    var selectedPickupType = 'Nearest Store';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Setup Courier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCourier,
                decoration: const InputDecoration(labelText: 'Courier name'),
                items: courierOptions
                    .map(
                      (courier) => DropdownMenuItem(
                        value: courier,
                        child: Text(courier),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCourier = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trackingController,
                decoration: const InputDecoration(labelText: 'Tracking number'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPickupType,
                decoration: const InputDecoration(labelText: 'Pickup type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Home Pickup',
                    child: Text('Home Pickup'),
                  ),
                  DropdownMenuItem(
                    value: 'Nearest Store',
                    child: Text('Nearest Store'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPickupType = value);
                  }
                },
              ),
              if (selectedPickupType == 'Home Pickup') ...[
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Additional charge: Rs. 250',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (trackingController.text.trim().isEmpty) return;
                try {
                  await OrderService().setupCourier(
                    orderId: order.id,
                    courierName: selectedCourier,
                    trackingNumber: trackingController.text.trim(),
                    pickupTime: DateTime.now().add(const Duration(days: 1)),
                    pickupType: selectedPickupType,
                    additionalPickupCharge: selectedPickupType == 'Home Pickup'
                        ? 250
                        : 0,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (error) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Could not setup courier: $error')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    trackingController.dispose();
  }

  Future<void> _downloadAddress(BuildContext context, AppOrder order) async {
    try {
      final buyer = await UserService().getUserById(order.userId);
      final buyerName = buyer?.name.isNotEmpty == true
          ? buyer!.name
          : _addressPart(order.deliveryAddress, 0, 'Not provided');
      final buyerPhone = buyer?.phone.isNotEmpty == true
          ? buyer!.phone
          : _addressPart(order.deliveryAddress, 1, 'Not provided');
      final htmlContent =
          '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Order ${order.orderNumber}</title></head>
<body>
<h1>AccessiTrade Order Address</h1>
<p><strong>Order number:</strong> ${_escapeHtml(order.orderNumber)}</p>
<p><strong>Buyer name:</strong> ${_escapeHtml(buyerName)}</p>
<p><strong>Phone number:</strong> ${_escapeHtml(buyerPhone)}</p>
<p><strong>Delivery address:</strong> ${_escapeHtml(order.deliveryAddress)}</p>
<p><strong>Order price:</strong> Rs. ${order.total.toStringAsFixed(2)}</p>
</body>
</html>
''';
      await downloadOrderDocument(
        fileName: 'order_${order.id}_address.doc',
        htmlContent: htmlContent,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buyer address document downloaded')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download address: $error')),
      );
    }
  }

  String _addressPart(String address, int index, String fallback) {
    final parts = address.split(', ');
    return parts.length > index && parts[index].isNotEmpty
        ? parts[index]
        : fallback;
  }

  String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

class _ActiveOrderCard extends StatelessWidget {
  final AppOrder order;
  final List<OrderItem> items;
  final VoidCallback onDownloadAddress;
  final VoidCallback onSetupCourier;

  const _ActiveOrderCard({
    required this.order,
    required this.items,
    required this.onDownloadAddress,
    required this.onSetupCourier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    order.statusLabel,
                    style: const TextStyle(
                      color: Color(0xFFE68A00),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFFFFF0D6),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your items in this order',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 6),
                ...items.map(
                  (item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.productName} × ${item.quantity}'),
                      Text(
                        'Rs. ${item.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Deliver to:',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDownloadAddress,
                    icon: const Icon(Icons.download_outlined, size: 17),
                    label: const Text('Download Address'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A5C5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onSetupCourier,
                    icon: const Icon(Icons.local_shipping_outlined, size: 17),
                    label: const Text('Setup Courier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
