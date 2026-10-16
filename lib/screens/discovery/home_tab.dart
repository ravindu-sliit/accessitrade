import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/models/product.dart';
import 'package:accessitrade/services/product_service.dart';
import 'package:accessitrade/services/cart_service.dart';
import 'package:accessitrade/services/cloudinary_service.dart';
import 'package:accessitrade/screens/discovery/search_screen.dart';
import 'package:accessitrade/screens/discovery/product_details_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _productService = ProductService();
  final _cartService = CartService();

  static final _categories = [
    {'label': 'Mobility Aids', 'icon': Icons.accessible},
    {'label': 'Daily Living', 'icon': Icons.restaurant},
    {'label': 'Vision Aids', 'icon': Icons.visibility},
  ];

  @override
  void initState() {
    super.initState();
    // Seed sample products if Firestore is empty
    _productService.seedSampleProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.watch<AccessibilityProvider>();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to AccessiTrade',
                      style: TextStyle(
                        fontSize: accessibility.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    Semantics(
                      label: 'Search products',
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: colorScheme.primary, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const SearchScreen())),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    const Icon(Icons.search, color: Colors.grey, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Search assistance tools...',
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: accessibility.bodyFontSize)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SearchScreen(autoStartVoice: true)),
                              ),
                              child: Semantics(
                                label: 'Voice search button',
                                button: true,
                                hint: 'Start voice search',
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(32)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.mic, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text('Speak',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: accessibility.smallFontSize,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Featured Categories
                    Text('Featured Categories',
                        style: TextStyle(fontSize: accessibility.bodyFontSize + 3, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: _categories.map((cat) {
                        return Expanded(
                          child: Semantics(
                            label: '${cat['label']} category',
                            button: true,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 48, height: 48,
                                      decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer, shape: BoxShape.circle),
                                      child: Icon(cat['icon'] as IconData,
                                          color: colorScheme.primary, size: 24),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(cat['label'] as String,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: accessibility.smallFontSize, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),
                    Text('Featured Products',
                        style: TextStyle(fontSize: accessibility.bodyFontSize + 3, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Real products from Firestore
            StreamBuilder<List<Product>>(
              stream: _productService.getFeaturedProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: colorScheme.primary),
                    )),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Text('Error loading products: ${snapshot.error}')),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No products yet', style: TextStyle(color: Colors.grey)),
                    )),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Semantics(
                          label:
                              '${product.name}, ${product.price}, rated ${product.rating} stars',
                          button: true,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product))),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: product.imageUrls.isNotEmpty
                                        ? Image.network(
                                            CloudinaryService.getThumbnailUrl(
                                                product.imageUrls.first,
                                                width: 80,
                                                height: 80),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            semanticLabel: product.altText.isNotEmpty
                                                ? product.altText
                                                : '${product.name} product image',
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 80,
                                              height: 80,
                                              color: const Color(0xFFE0F2F1),
                                              child: Icon(Icons.shopping_bag_outlined,
                                                  color: colorScheme.primary, size: 40),
                                            ),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: const Color(0xFFE0F2F1),
                                            child: Icon(Icons.shopping_bag_outlined,
                                                color: colorScheme.primary, size: 40),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: accessibility.bodyFontSize),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rs. ${product.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: accessibility.bodyFontSize),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 14),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${product.rating} (${product.reviewCount} reviews)',
                                                style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: accessibility.smallFontSize),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Semantics(
                                    label: 'Add ${product.name} to cart',
                                    button: true,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await _cartService.addToCart(product);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('Added to cart'),
                                            backgroundColor: colorScheme.primary,
                                            duration: Duration(seconds: 1),
                                          ));
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 16),
                                      label: Text('Add to Cart',
                                          style: TextStyle(fontSize: accessibility.smallFontSize)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(32)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: products.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}