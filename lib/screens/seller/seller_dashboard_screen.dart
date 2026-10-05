import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/models/product.dart';
import 'package:accessitrade/models/order.dart';
import 'package:accessitrade/services/seller_service.dart';
import 'package:accessitrade/services/order_service.dart';
import 'package:accessitrade/services/cloudinary_service.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:accessitrade/screens/seller/active_orders_screen.dart';
import 'package:accessitrade/screens/seller/product_inventory_screen.dart';
import 'package:accessitrade/screens/seller/seller_profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final _sellerService = SellerService();
  final _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF8),
      drawer: _SellerNavigationDrawer(
        onProfile: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellerProfileScreen()),
          );
        },
        onActiveOrders: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActiveOrdersScreen()),
          );
        },
        onInventory: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductInventoryScreen()),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: StreamBuilder<Map<String, dynamic>>(
          stream: Stream.fromFuture(_sellerService.getStats()),
          builder: (context, snap) {
            final rating = 4.8;
            return Row(
              children: [
                const Expanded(
                  child: Text(
                    'Seller Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$rating ★',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _sellerService.getMyProducts(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];

          return StreamBuilder<List<AppOrder>>(
            stream: _sellerService.getMyOrders(),
            builder: (context, orderSnap) {
              final orders = orderSnap.data ?? [];
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SellerSummary(products: products, orders: orders),

                    if (false) ...[
                      // Product Inventory
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Product Inventory',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.list, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                      else if (products.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No products listed yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showAddProductSheet(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Your First Product'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                // Search inventory
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search inventory...',
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                ...products.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final product = entry.value;
                                  final isLast = i == products.length - 1;
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: isLast
                                          ? null
                                          : Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade100,
                                              ),
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              'Rs. ${product.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                product.category,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${product.stockQty} in stock',
                                              style: TextStyle(
                                                color: product.stockQty > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Semantics(
                                              label: 'Edit ${product.name}',
                                              button: true,
                                              child: OutlinedButton.icon(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 14,
                                                ),
                                                label: const Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      colorScheme.primary,
                                                  side: BorderSide(
                                                    color: colorScheme.primary,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          32,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Semantics(
                                              label: 'Remove ${product.name}',
                                              button: true,
                                              child: OutlinedButton.icon(
                                                onPressed: () => _confirmDelete(
                                                  context,
                                                  product,
                                                ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 14,
                                                ),
                                                label: const Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  side: const BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          32,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Publish item button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Semantics(
                          label: 'Publish new item button',
                          button: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddProductSheet(context),
                              icon: const Icon(Icons.add),
                              label: const Text(
                                'Publish item',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }, // end orders StreamBuilder builder
          ); // end orders StreamBuilder
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Product'),
        content: Text('Remove "${product.name}" from your listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sellerService.deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddProductSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final altTextCtrl = TextEditingController();
    String selectedCategory = 'Mobility Aids';
    bool isLoading = false;
    XFile? _selectedImage;
    String? _uploadedImageUrl;
    bool _isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Photo upload section
                Semantics(
                  label: 'Upload product photo button',
                  button: true,
                  child: GestureDetector(
                    onTap: () async {
                      final cloudinary = CloudinaryService();
                      final picked = await cloudinary.pickFromGallery();
                      if (picked != null) {
                        setSheetState(() => _isUploading = true);
                        try {
                          final url = await cloudinary.uploadImage(picked);
                          setSheetState(() {
                            _selectedImage = picked;
                            _uploadedImageUrl = url;
                            _isUploading = false;
                          });
                        } catch (e) {
                          setSheetState(() => _isUploading = false);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1A5C5A),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _isUploading
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFF1A5C5A),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(color: Color(0xFF1A5C5A)),
                                  ),
                                ],
                              ),
                            )
                          : _uploadedImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _uploadedImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 140,
                                semanticLabel: 'Uploaded product photo',
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: Color(0xFF1A5C5A),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to upload photo',
                                  style: TextStyle(color: Color(0xFF1A5C5A)),
                                ),
                                Text(
                                  'JPG, PNG up to 5MB',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _sheetField(
                  nameCtrl,
                  'Product Name',
                  'e.g. Ergonomic Walker Frame',
                ),
                const SizedBox(height: 12),
                _sheetField(
                  descCtrl,
                  'Description',
                  'Describe your product...',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _sheetField(
                  altTextCtrl,
                  'Accessibility Description (Alt Text)',
                  'Describe the product for screen readers...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  items:
                      [
                            'Mobility Aids',
                            'Vision Aids',
                            'Hearing Aids',
                            'Daily Living Aids',
                            'Sensory Aids',
                            'Clothing',
                          ]
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (v) => setSheetState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _sheetField(priceCtrl, 'Price (Rs.)', '0')),
                    const SizedBox(width: 12),
                    Expanded(child: _sheetField(stockCtrl, 'Stock Qty', '0')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty)
                              return;
                            setSheetState(() => isLoading = true);
                            try {
                              await _sellerService.addProduct(
                                name: nameCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                price: double.tryParse(priceCtrl.text) ?? 0,
                                category: selectedCategory,
                                altText: altTextCtrl.text.trim(),
                                stockQty: int.tryParse(stockCtrl.text) ?? 0,
                                imageUrl:
                                    _uploadedImageUrl, // pass the uploaded URL
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              setSheetState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Publish Listing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCourierSheetForOrder(BuildContext context, AppOrder order) {
    final courierController = TextEditingController();
    final trackingController = TextEditingController();
    DateTime selectedPickup = DateTime.now().add(const Duration(hours: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Setup Courier — ${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'To: ${order.deliveryAddress}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _SheetTextField(
                label: 'Courier name',
                hint: 'e.g. Pronto, DHL, PickMe Flash',
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                label: 'Tracking number',
                hint: 'e.g. PRN-123456',
              ),
              const SizedBox(height: 12),
              // Pickup time selector
              GestureDetector(
                onTap: () async {
                  final picked = await showDateTimePicker(ctx, selectedPickup);
                  if (picked != null)
                    setModalState(() => selectedPickup = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pickup: ${selectedPickup.day}/${selectedPickup.month} '
                        '${selectedPickup.hour.toString().padLeft(2, '0')}:'
                        '${selectedPickup.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await _orderService.setupCourier(
                        orderId: order.id,
                        courierName: courierController.text.isNotEmpty
                            ? courierController.text
                            : 'Courier',
                        trackingNumber: trackingController.text.isNotEmpty
                            ? trackingController.text
                            : 'TBD',
                        pickupTime: selectedPickup,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Courier setup successfully'),
                            backgroundColor: Color(0xFF1A5C5A),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Confirm Courier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(
    BuildContext context,
    DateTime initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return null;
    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF1A5C5A), width: 2),
        ),
      ),
    );
  }
}

// ── Incoming Order Card ────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final AppOrder order;
  final List<OrderItem> myItems;
  final VoidCallback onSetupCourier;
  final Future<void> Function(OrderStatus) onUpdateStatus;
  final ColorScheme colorScheme;
  final bool showProcessingAction;

  const _OrderCard({
    required this.order,
    required this.myItems,
    required this.onSetupCourier,
    required this.onUpdateStatus,
    required this.colorScheme,
    this.showProcessingAction = false,
  });

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCourier =
        order.courierName != null && order.courierName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items belonging to this seller
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your items in this order',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                ...myItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} × ${item.quantity}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          'Rs. ${item.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deliver to:',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        textAlign: TextAlign.end,
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

          // Courier info if set
          if (hasCourier)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.courierName}  •  ${order.trackingNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              children: [
                if (!showProcessingAction)
                  Expanded(
                    child: Semantics(
                      label: hasCourier
                          ? 'Update courier for order ${order.orderNumber}'
                          : 'Setup courier for order ${order.orderNumber}',
                      button: true,
                      child: ElevatedButton.icon(
                        onPressed: onSetupCourier,
                        icon: Icon(
                          hasCourier
                              ? Icons.edit_outlined
                              : Icons.local_shipping_outlined,
                          size: 16,
                        ),
                        label: Text(
                          hasCourier ? 'Update Courier' : 'Setup Courier',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!showProcessingAction) const SizedBox(width: 8),
                if (showProcessingAction)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await onUpdateStatus(OrderStatus.processing);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Processing'),
                    ),
                  ),
                // Mark as Shipped (quick action)
                if (!showProcessingAction &&
                    (order.status == OrderStatus.confirmed ||
                        order.status == OrderStatus.processing))
                  OutlinedButton(
                    onPressed: () async {
                      await onUpdateStatus(OrderStatus.shipped);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Mark Shipped',
                      style: TextStyle(fontSize: 13),
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

class _SellerNavigationDrawer extends StatelessWidget {
  final VoidCallback onProfile;
  final VoidCallback onActiveOrders;
  final VoidCallback onInventory;

  const _SellerNavigationDrawer({
    required this.onProfile,
    required this.onActiveOrders,
    required this.onInventory,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'AccessiTrade\nSeller Centre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: onProfile,
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Active Orders'),
              onTap: onActiveOrders,
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Product Inventory'),
              onTap: onInventory,
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerSummary extends StatefulWidget {
  final List<Product> products;
  final List<AppOrder> orders;

  const _SellerSummary({required this.products, required this.orders});

  @override
  State<_SellerSummary> createState() => _SellerSummaryState();
}

class _SellerSummaryState extends State<_SellerSummary> {
  int _revenueDays = 7;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final orders = widget.orders;
    final currentMonthOrders = orders.where((order) {
      return order.createdAt.year == today.year &&
          order.createdAt.month == today.month;
    }).toList();
    final monthRevenue = currentMonthOrders.fold<double>(
      0,
      (sum, order) => sum + _sellerOrderTotal(order),
    );
    final activeOrders = orders
        .where((order) => order.status == OrderStatus.placed)
        .length;
    final activeOrderCount = orders
        .where(
          (order) =>
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled,
        )
        .length;
    final processingOrders = orders
        .where((order) => order.status == OrderStatus.processing)
        .length;
    final readyForPickup = orders
        .where(
          (order) =>
              order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.shipped,
        )
        .length;
    final outForDelivery = orders
        .where((order) => order.status == OrderStatus.outForDelivery)
        .length;
    final barValues = List<double>.generate(_revenueDays, (index) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: _revenueDays - 1 - index));
      return orders
          .where(
            (order) =>
                order.createdAt.year == date.year &&
                order.createdAt.month == date.month &&
                order.createdAt.day == date.day,
          )
          .fold<double>(0, (sum, order) => sum + _sellerOrderTotal(order));
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 420 ? 2 : 1;
              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 2 ? 1.75 : 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _SummaryMetric(
                    label: 'Month Revenue',
                    value: 'LKR ${monthRevenue.toStringAsFixed(2)}',
                    icon: Icons.payments_outlined,
                    accent: const Color(0xFF0E8174),
                  ),
                  _SummaryMetric(
                    label: 'Remain to Ship',
                    value: '${activeOrders + processingOrders}',
                    icon: Icons.inventory_outlined,
                    accent: const Color(0xFF3A9D82),
                  ),
                  _SummaryMetric(
                    label: 'Active Orders',
                    value: '$activeOrderCount',
                    icon: Icons.shopping_bag_outlined,
                    accent: const Color(0xFF2D806D),
                  ),
                  _SummaryMetric(
                    label: 'Listed Items',
                    value: '${widget.products.length}',
                    icon: Icons.sell_outlined,
                    accent: const Color(0xFF58B79A),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 2 : 1;
              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 2 ? .9 : 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _SummaryPanel(
                    title: 'Order Status',
                    icon: Icons.donut_large_rounded,
                    accent: const Color(0xFF1A5C5A),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150,
                          child: CustomPaint(
                            painter: _StatusPiePainter(
                              active: activeOrders,
                              processing: processingOrders,
                              readyForPickup: readyForPickup,
                              outForDelivery: outForDelivery,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${activeOrders + processingOrders + readyForPickup + outForDelivery}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B3E43),
                                    ),
                                  ),
                                  Text(
                                    'Total Orders',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _StatusLegend(
                          items: [
                            ('Active', const Color(0xFF1A5C5A), activeOrders),
                            (
                              'Processing',
                              const Color(0xFF3A9D82),
                              processingOrders,
                            ),
                            ('Ready', const Color(0xFF58B79A), readyForPickup),
                            ('Out', const Color(0xFF9ACDB8), outForDelivery),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _SummaryPanel(
                    title: 'Revenue',
                    icon: Icons.insights_rounded,
                    accent: const Color(0xFF1A5C5A),
                    trailing: DropdownButton<int>(
                      value: _revenueDays,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 days')),
                        DropdownMenuItem(value: 30, child: Text('30 days')),
                        DropdownMenuItem(value: 90, child: Text('90 days')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _revenueDays = value);
                      },
                    ),
                    child: SizedBox(
                      height: 190,
                      child: CustomPaint(
                        painter: _SalesBarPainter(values: barValues),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            barValues.every((value) => value == 0)
                                ? 'No revenue in this period'
                                : 'Revenue trend',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _sellerOrderTotal(AppOrder order) {
    final sellerId = SellerService().currentSellerId;
    final sellerItems = sellerId == null
        ? order.items
        : order.items.where((item) => item.sellerId == sellerId);
    return sellerItems.fold<double>(0, (sum, item) => sum + item.subtotal);
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0x180B3E43),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF087267), size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF092F34),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF62747B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded, color: accent, size: 19),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;
  final Color accent;
  final Widget? trailing;

  const _SummaryPanel({
    required this.title,
    required this.child,
    required this.icon,
    required this.accent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  final List<(String, Color, int)> items;

  const _StatusLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '${item.$1}: ${item.$3}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _StatusPiePainter extends CustomPainter {
  final int active;
  final int processing;
  final int readyForPickup;
  final int outForDelivery;

  _StatusPiePainter({
    required this.active,
    required this.processing,
    required this.readyForPickup,
    required this.outForDelivery,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = active + processing + readyForPickup + outForDelivery;
    final diameter = size.shortestSide;
    final chartOffset = Offset(
      (size.width - diameter) / 2,
      (size.height - diameter) / 2,
    );
    final rect = chartOffset & Size.square(diameter);
    final paint = Paint()..style = PaintingStyle.fill;
    final center = rect.center;
    final radius = diameter / 2;
    if (total == 0) {
      paint.color = Colors.grey.shade200;
      canvas.drawCircle(center, radius, paint);
      paint.color = const Color(0xFFF4FAF8);
      canvas.drawCircle(center, radius * .54, paint);
      return;
    }
    var start = -3.14159 / 2;
    final values = [
      (active, const Color(0xFF1A5C5A)),
      (processing, const Color(0xFF3A9D82)),
      (readyForPickup, const Color(0xFF58B79A)),
      (outForDelivery, const Color(0xFF9ACDB8)),
    ];
    for (final entry in values) {
      if (entry.$1 == 0) continue;
      paint.color = entry.$2;
      final sweep = entry.$1 / total * 6.28318;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
    paint.color = const Color(0xFFF4FAF8);
    canvas.drawCircle(center, radius * .54, paint);
  }

  @override
  bool shouldRepaint(covariant _StatusPiePainter oldDelegate) => true;
}

class _SalesBarPainter extends CustomPainter {
  final List<double> values;

  _SalesBarPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final paint = Paint()..color = const Color(0xFF1A5C5A);
    final width = size.width / values.length;
    for (var index = 0; index < values.length; index++) {
      final height = maxValue == 0
          ? 4.0
          : (values[index] / maxValue) * (size.height - 12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            index * width + width * .25,
            size.height - height,
            width * .5,
            height,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SalesBarPainter oldDelegate) => true;
}

class _SheetTextField extends StatelessWidget {
  final String hint;
  final String label;
  final int maxLines;

  const _SheetTextField({
    required this.hint,
    required this.label,
    this.maxLines = 1,
  });

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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
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
            borderSide: const BorderSide(color: Color(0xFF1A5C5A), width: 2),
          ),
        ),
      ),
    );
  }
}
