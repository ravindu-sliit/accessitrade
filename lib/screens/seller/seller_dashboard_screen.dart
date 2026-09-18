import 'package:flutter/material.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final List<Map<String, dynamic>> _listings = [
    {
      'name': 'Handmade Fidget Ring',
      'price': 'Rs. 450',
      'stock': 12,
      'orders': 5,
      'status': 'Active',
    },
    {
      'name': 'Woven Sensory Bracelet',
      'price': 'Rs. 680',
      'stock': 7,
      'orders': 2,
      'status': 'Active',
    },
    {
      'name': 'Tactile Wall Hanging',
      'price': 'Rs. 2,200',
      'stock': 0,
      'orders': 0,
      'status': 'Out of Stock',
    },
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#AM-2024-0847',
      'item': 'Handmade Fidget Ring x2',
      'buyer': 'Kamala F.',
      'total': 'Rs. 900',
      'status': 'New',
      'date': 'Today, 10:32 AM',
    },
    {
      'id': '#AM-2024-0821',
      'item': 'Woven Sensory Bracelet x1',
      'buyer': 'Nimal P.',
      'total': 'Rs. 680',
      'status': 'Ready',
      'date': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5C5A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Shop',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Semantics(
            label: 'Add new product listing',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddListingSheet(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats summary
            Container(
              color: const Color(0xFF1A5C5A),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  _StatCard(label: 'Total Sales', value: 'Rs. 12,400', icon: Icons.payments_outlined),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Orders', value: '7 Active', icon: Icons.shopping_bag_outlined),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Rating', value: '4.8 ★', icon: Icons.star_outline),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // New Orders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Incoming Orders',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All',
                        style: TextStyle(color: Color(0xFF1A5C5A))),
                  ),
                ],
              ),
            ),

            ..._orders.map((order) => _OrderCard(
                  order: order,
                  onPickup: () => _showCourierPickupSheet(context, order),
                )),

            const SizedBox(height: 8),

            // My Listings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Listings',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Semantics(
                    label: 'Add new listing button',
                    button: true,
                    child: TextButton.icon(
                      onPressed: () => _showAddListingSheet(context),
                      icon: const Icon(Icons.add, color: Color(0xFF1A5C5A)),
                      label: const Text('Add New',
                          style: TextStyle(color: Color(0xFF1A5C5A))),
                    ),
                  ),
                ],
              ),
            ),

            ..._listings.map((listing) => _ListingCard(listing: listing)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showAddListingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddListingSheet(),
    );
  }

  void _showCourierPickupSheet(
      BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CourierPickupSheet(order: order),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onPickup;

  const _OrderCard({required this.order, required this.onPickup});

  @override
  Widget build(BuildContext context) {
    final isNew = order['status'] == 'New';
    return Semantics(
      label:
          'Order ${order['id']}, ${order['item']}, ${order['total']}, status: ${order['status']}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['id'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5C5A))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNew
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                        color: isNew ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order['item'],
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('Buyer: ${order['buyer']} • ${order['date']}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(order['total'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5C5A),
                        fontSize: 16)),
                const Spacer(),
                Semantics(
                  label: 'Schedule courier pickup for order ${order['id']}',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: onPickup,
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: const Text('Schedule Pickup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = listing['stock'] == 0;
    return Semantics(
      label:
          '${listing['name']}, ${listing['price']}, stock: ${listing['stock']}, status: ${listing['status']}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Color(0xFF1A5C5A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(listing['price'],
                      style: const TextStyle(
                          color: Color(0xFF1A5C5A),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Stock: ${listing['stock']} • Orders: ${listing['orders']}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                listing['status'],
                style: TextStyle(
                    color: isOutOfStock ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddListingSheet extends StatelessWidget {
  const _AddListingSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Listing',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Photo upload
            Semantics(
              label: 'Upload product photo button',
              button: true,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF1A5C5A),
                        style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 40, color: Color(0xFF1A5C5A)),
                      SizedBox(height: 8),
                      Text('Tap to upload photo',
                          style: TextStyle(color: Color(0xFF1A5C5A))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SheetTextField(hint: 'Product name', label: 'Product name input'),
            const SizedBox(height: 12),
            _SheetTextField(
                hint: 'Accessibility description (alt-text)',
                label: 'Accessibility description input',
                maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _SheetTextField(
                        hint: 'Price (Rs.)', label: 'Price input')),
                const SizedBox(width: 12),
                Expanded(
                    child: _SheetTextField(
                        hint: 'Stock qty', label: 'Stock quantity input')),
              ],
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Publish listing button',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Publish Listing',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CourierPickupSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  const _CourierPickupSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Schedule Courier Pickup',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Order ${order['id']}',
                style: const TextStyle(
                    color: Color(0xFF1A5C5A),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _SheetTextField(
                hint: 'Pickup address (auto-filled from profile)',
                label: 'Pickup address input'),
            const SizedBox(height: 12),
            _SheetTextField(
                hint: 'Preferred pickup date',
                label: 'Preferred pickup date input'),
            const SizedBox(height: 12),
            _SheetTextField(
                hint: 'Preferred time slot (e.g. 9am - 12pm)',
                label: 'Preferred time slot input'),
            const SizedBox(height: 12),
            _SheetTextField(
                hint: 'Special instructions for courier (optional)',
                label: 'Special instructions input',
                maxLines: 2),
            const SizedBox(height: 20),
            Semantics(
              label: 'Confirm courier pickup button',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Courier pickup scheduled successfully'),
                        backgroundColor: Color(0xFF1A5C5A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Confirm Pickup',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final String hint;
  final String label;
  final int maxLines;

  const _SheetTextField(
      {required this.hint, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide:
                const BorderSide(color: Color(0xFF1A5C5A), width: 2),
          ),
        ),
      ),
    );
  }
}
// updated
// updated
