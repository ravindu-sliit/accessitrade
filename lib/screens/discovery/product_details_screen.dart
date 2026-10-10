import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';
import 'package:accessitrade/services/voice_command_service.dart';
import 'package:accessitrade/widgets/voice_fab.dart';
import 'package:accessitrade/services/cart_service.dart';
import 'package:accessitrade/models/product.dart';
import 'package:accessitrade/screens/discovery/reviews_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;
  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _qty = 1;
  int _imageIndex = 0;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Auto-read product details after screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoReadProduct();
      _registerVoiceCommands();
    });
  }

  void _autoReadProduct() {
    final accessibility = context.read<AccessibilityProvider>();
    // Only auto-read if voice features are enabled
    if (!accessibility.voiceEnabled) return;
    
    final product = widget.product;
    if (product != null) {
      accessibility.speakProductDetails(
        name: product.name,
        price: product.price,
        rating: product.rating,
        reviewCount: product.reviewCount,
        description: product.description,
        sellerName: product.sellerName,
        inStock: product.inStock,
      );
    }
  }

  void _registerVoiceCommands() {
    final voiceNav = context.read<VoiceNavigationProvider>();
    final accessibility = context.read<AccessibilityProvider>();
    
    // Sync voice enabled setting
    voiceNav.setVoiceEnabled(accessibility.voiceEnabled);
    
    voiceNav.setScreen('product_details');
    
    voiceNav.registerScreenCommands('product_details', [
      VoiceCommand(
        name: 'add_to_cart',
        pattern: r'^(add|cart|add\s*to\s*cart|add\s*this|buy|purchase).*$',
        description: 'Add product to cart',
        action: (context, params) async {
          debugPrint('🛒 Adding to cart...');
          await _addToCart();
        },
      ),
      VoiceCommand(
        name: 'go_back',
        pattern: r'^(go\s*back|back|return|close)$',
        description: 'Go back to previous screen',
        action: (context, params) async {
          final voiceNav = context.read<VoiceNavigationProvider>();
          voiceNav.announce('Going back');
          Navigator.pop(context);
        },
      ),
      VoiceCommand(
        name: 'read_description',
        pattern: r'^(read|describe|tell|details|description).*$',
        description: 'Read product description',
        action: (context, params) async {
          _autoReadProduct();
        },
      ),
      VoiceCommand(
        name: 'increase_quantity',
        pattern: r'^(increase|more|plus|add\s*one).*$',
        description: 'Increase quantity',
        action: (context, params) async {
          setState(() => _qty++);
          final voiceNav = context.read<VoiceNavigationProvider>();
          voiceNav.announce('Quantity is now $_qty');
        },
      ),
      VoiceCommand(
        name: 'decrease_quantity',
        pattern: r'^(decrease|less|minus|reduce|remove\s*one).*$',
        description: 'Decrease quantity',
        action: (context, params) async {
          if (_qty > 1) {
            setState(() => _qty--);
            final voiceNav = context.read<VoiceNavigationProvider>();
            voiceNav.announce('Quantity is now $_qty');
          } else {
            final voiceNav = context.read<VoiceNavigationProvider>();
            voiceNav.announce('Quantity is already at minimum');
          }
        },
      ),
      VoiceCommand(
        name: 'go_to_cart',
        pattern: r'^(go\s*to\s*cart|view\s*cart|open\s*cart|checkout)$',
        description: 'Go to cart',
        action: (context, params) async {
          final voiceNav = context.read<VoiceNavigationProvider>();
          voiceNav.announce('Opening cart');
          // Pop back and navigate to cart tab
          Navigator.pop(context);
          voiceNav.onTabChange?.call(2); // Cart is tab index 2
        },
      ),
    ]);
  }

  Future<void> _addToCart() async {
    final product = widget.product;
    if (product != null) {
      final colorScheme = Theme.of(context).colorScheme;
      final voiceNav = context.read<VoiceNavigationProvider>();
      
      for (int i = 0; i < _qty; i++) {
        await _cartService.addToCart(product);
      }
      
      voiceNav.announce('Added $_qty ${product.name} to cart');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $_qty item(s) to cart'),
            backgroundColor: colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    try {
      final voiceNav = context.read<VoiceNavigationProvider>();
      voiceNav.unregisterScreenCommands('product_details');
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.watch<AccessibilityProvider>();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: const VoiceFAB(),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text('Product Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: accessibility.bodyFontSize)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('Categories > Mobility Aids > Wheelchairs',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: accessibility.smallFontSize)),
            ),

            // Image carousel
            Container(
              height: 280,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: Semantics(
                      label: widget.product?.altText.isNotEmpty == true
                          ? widget.product!.altText
                          : '${widget.product?.name ?? "Foldable wheelchair"} product image',
                      child: Container(
                        width: double.infinity,
                        height: 260,
                        color: Colors.white,
                        child: widget.product?.imageUrls != null && widget.product!.imageUrls.isNotEmpty
                            ? Image.network(
                                widget.product!.imageUrls.first,
                                fit: BoxFit.contain,
                                semanticLabel: widget.product!.altText.isNotEmpty
                                    ? widget.product!.altText
                                    : '${widget.product!.name} product image',
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.wheelchair_pickup,
                                        size: 140, color: Color(0xFFCCCCCC)),
                              )
                            : const Icon(Icons.wheelchair_pickup,
                                size: 140, color: Color(0xFFCCCCCC)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Container(
                        width: i == _imageIndex ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _imageIndex
                              ? colorScheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listen button
                  Consumer<AccessibilityProvider>(
                    builder: (context, accessibility, _) => Semantics(
                      label: accessibility.isSpeaking
                          ? 'Stop audio, currently reading product details'
                          : 'Listen to product details as audio',
                      button: true,
                      child: GestureDetector(
                        onTap: () {
                          if (accessibility.isSpeaking) {
                            accessibility.stop();
                          } else {
                            final product = widget.product;
                            accessibility.speakProductDetails(
                              name: product?.name ?? 'Foldable Wheelchair',
                              price: product?.price ?? 45000,
                              rating: product?.rating ?? 4.2,
                              reviewCount: product?.reviewCount ?? 128,
                              description: product?.description ?? 'An ultra-lightweight compact steel wheelchair.',
                              sellerName: product?.sellerName ?? 'MediCare Solutions',
                              inStock: product?.inStock ?? true,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: accessibility.isSpeaking
                                ? Colors.orange.shade50
                                : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accessibility.isSpeaking
                                  ? Colors.orange
                                  : colorScheme.primary,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                accessibility.isSpeaking
                                    ? Icons.stop_circle_outlined
                                    : Icons.volume_up_outlined,
                                color: accessibility.isSpeaking
                                    ? Colors.orange
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                accessibility.isSpeaking
                                    ? 'Stop Audio'
                                    : 'Listen to Product Details (Audio)',
                                style: TextStyle(
                                  color: accessibility.isSpeaking
                                      ? Colors.orange
                                      : colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name + rating
                  Text(widget.product?.name ?? 'Foldable Wheelchair',
                      style: TextStyle(fontSize: accessibility.titleFontSize, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'View ${widget.product?.reviewCount ?? 128} customer reviews, rated ${widget.product?.rating ?? 4.2} stars. Tap to read reviews.',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.product != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewsScreen(
                                productId: widget.product!.id,
                                productName: widget.product!.name,
                                averageRating: widget.product!.rating,
                                reviewCount: widget.product!.reviewCount,
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product?.rating ?? 4.2} (${widget.product?.reviewCount ?? 128} reviews)',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: accessibility.bodyFontSize - 1,
                                decoration: TextDecoration.underline),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios,
                              size: 12, color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Row(
                    children: [
                      Text('Rs. ${(widget.product?.price ?? 45000).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: accessibility.titleFontSize + 2,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary)),
                      const SizedBox(width: 12),
                      Text('Rs. ${((widget.product?.price ?? 45000) * 1.15).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: accessibility.bodyFontSize,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text('In Stock',
                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('MediCare Solutions Verified',
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Description
                  const Text('Product Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product?.description ?? 'An ultra-lightweight, compact steel wheelchair built with ergonomic armrests and swing-away leg rests. Perfect for transport and independent movement across smooth or rough surfaces.',
                    style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF444444)),
                  ),

                  const SizedBox(height: 20),

                  // Specifications
                  const Text('Specifications',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _specTable(),

                  const SizedBox(height: 24),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Reviews preview section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Customer Reviews',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (widget.product != null)
                        Semantics(
                          label: 'See all reviews button',
                          button: true,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewsScreen(
                                  productId: widget.product!.id,
                                  productName: widget.product!.name,
                                  averageRating: widget.product!.rating,
                                  reviewCount: widget.product!.reviewCount,
                                ),
                              ),
                            ),
                            child: Text('See All',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating summary bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              '${widget.product?.rating ?? 4.2}',
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Icon(Icons.star_half, color: Colors.amber, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.product?.reviewCount ?? 128} reviews',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Semantics(
                            label: 'Write a review button',
                            button: true,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (widget.product != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReviewsScreen(
                                        productId: widget.product!.id,
                                        productName: widget.product!.name,
                                        averageRating: widget.product!.rating,
                                        reviewCount: widget.product!.reviewCount,
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.rate_review_outlined, size: 18),
                              label: const Text('Write a Review'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity
                  Row(
                    children: [
                      const Text('Quantity',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Semantics(
                        label: 'Decrease quantity',
                        button: true,
                        child: GestureDetector(
                          onTap: () { if (_qty > 1) setState(() => _qty--); },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.remove, color: colorScheme.primary),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('$_qty',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Semantics(
                        label: 'Increase quantity',
                        button: true,
                        child: GestureDetector(
                          onTap: () => setState(() => _qty++),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, color: colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Add to wishlist button',
                          button: true,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Add to Wishlist',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          label: 'Add to cart button',
                          button: true,
                          child: ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Add to Cart',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specTable() {
    final specs = [
      ['Size', 'Standard Adult (18 inch seat)'],
      ['Material', 'Alloy Steel & Breathable Mesh'],
      ['Weight', '11.5 kg (Easy to lift)'],
      ['Features', 'Foldable backrest, Dual brakes'],
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: specs.asMap().entries.map((entry) {
          final i = entry.key;
          final spec = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i < specs.length - 1
                  ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(spec[0],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Expanded(
                  child: Text(spec[1],
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}