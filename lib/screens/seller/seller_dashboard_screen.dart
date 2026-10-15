import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/models/product.dart';
import 'package:accessitrade/services/seller_service.dart';
import 'package:accessitrade/services/cloudinary_service.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:image_picker/image_picker.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final _sellerService = SellerService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                const Text('Seller Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.visibility, size: 16),
                Text(' $rating ★', style: const TextStyle(fontSize: 13)),
              ],
            );
          },
        ),
        actions: [
          Semantics(
            label: 'Add new product listing',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddProductSheet(context),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _sellerService.getMyProducts(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats header
                Container(
                  color: colorScheme.primary,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      _StatCard(
                          label: 'Products Listed',
                          value: '${products.length}',
                          icon: Icons.inventory_2_outlined),
                      const SizedBox(width: 12),
                      _StatCard(
                          label: 'Active Orders',
                          value: '0',
                          icon: Icons.shopping_bag_outlined),
                      const SizedBox(width: 12),
                      _StatCard(
                          label: 'Rating',
                          value: '4.8 ★',
                          icon: Icons.star_outline),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Logistics section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
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
                            const Text('Logistics',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Icon(Icons.local_shipping_outlined,
                                color: Colors.grey.shade400),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('NEXT SCHEDULED PICKUP',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        const SizedBox(height: 4),
                        const Text('No pickup scheduled',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Semantics(
                          label: 'Schedule courier pickup button',
                          button: true,
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _showCourierSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)),
                              ),
                              child: const Text('Schedule Courier Pickup',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('• ${products.length} products listed',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Product Inventory
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Product Inventory',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                        color: colorScheme.primary),
                  ))
                else if (products.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('No products listed yet',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddProductSheet(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
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
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
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
                                            color: Colors.grey.shade100)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'Rs. ${product.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(product.category,
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 11)),
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
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 14),
                                          label: const Text('Edit',
                                              style: TextStyle(fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                colorScheme.primary,
                                            side: BorderSide(
                                                color: colorScheme.primary),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Semantics(
                                        label: 'Remove ${product.name}',
                                        button: true,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _confirmDelete(context, product),
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              size: 14),
                                          label: const Text('Remove',
                                              style: TextStyle(fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(
                                                color: Colors.red),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
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
                        label: const Text('+ Publish item',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add New Product',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
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
                                  CircularProgressIndicator(color: Color(0xFF1A5C5A)),
                                  SizedBox(height: 8),
                                  Text('Uploading...', style: TextStyle(color: Color(0xFF1A5C5A))),
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
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 40, color: Color(0xFF1A5C5A)),
                                    SizedBox(height: 8),
                                    Text('Tap to upload photo',
                                        style: TextStyle(color: Color(0xFF1A5C5A))),
                                    Text('JPG, PNG up to 5MB',
                                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                _sheetField(nameCtrl, 'Product Name', 'e.g. Ergonomic Walker Frame'),
                const SizedBox(height: 12),
                _sheetField(descCtrl, 'Description', 'Describe your product...', maxLines: 3),
                const SizedBox(height: 12),
                _sheetField(altTextCtrl, 'Accessibility Description (Alt Text)',
                    'Describe the product for screen readers...', maxLines: 2),
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
                  items: [
                    'Mobility Aids', 'Vision Aids', 'Hearing Aids',
                    'Daily Living Aids', 'Sensory Aids', 'Clothing'
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                            if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                            setSheetState(() => isLoading = true);
                            try {
                              await _sellerService.addProduct(
                                name: nameCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                price: double.tryParse(priceCtrl.text) ?? 0,
                                category: selectedCategory,
                                altText: altTextCtrl.text.trim(),
                                stockQty: int.tryParse(stockCtrl.text) ?? 0,
                                imageUrl: _uploadedImageUrl,  // pass the uploaded URL
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
                          borderRadius: BorderRadius.circular(32)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24, width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Publish Listing',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showCourierSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Schedule Courier Pickup',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _sheetField(TextEditingController(), 'Pickup Address',
                  'Auto-filled from your profile'),
              const SizedBox(height: 12),
              _sheetField(TextEditingController(), 'Preferred Date',
                  'e.g. Oct 25, 2026'),
              const SizedBox(height: 12),
              _sheetField(TextEditingController(), 'Time Slot',
                  'e.g. 9am - 12pm'),
              const SizedBox(height: 12),
              _sheetField(
                  TextEditingController(),
                  'Special Instructions (optional)',
                  'e.g. Ring bell twice',
                  maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Courier pickup scheduled'),
                        backgroundColor: const Color(0xFF1A5C5A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Confirm Pickup',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide:
              BorderSide(color: const Color(0xFF1A5C5A), width: 2),
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
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
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center),
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
