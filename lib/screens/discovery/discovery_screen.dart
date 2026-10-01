import 'package:flutter/material.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Tactile', 'Sensory', 'Mobility', 'Visual', 'Hearing', 'Daily Living'
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Tactile Sensory Ball',
      'seller': 'AccessAbility Store',
      'price': 'Rs. 850',
      'rating': 4.5,
      'reviews': 23,
      'tag': 'Tactile',
      'altText': 'Soft rubber tactile ball with raised bumps for sensory stimulation',
      'isVerified': true,
    },
    {
      'name': 'Braille Writing Slate',
      'seller': 'Inclusive Tools LK',
      'price': 'Rs. 1,200',
      'rating': 4.8,
      'reviews': 45,
      'tag': 'Visual',
      'altText': 'Metal braille writing slate with stylus for embossing braille text',
      'isVerified': true,
    },
    {
      'name': 'Non-Slip Grip Cutlery Set',
      'seller': 'EasyLiving Lanka',
      'price': 'Rs. 2,500',
      'rating': 4.2,
      'reviews': 17,
      'tag': 'Daily Living',
      'altText': 'Ergonomic cutlery set with wide non-slip handles for easy gripping',
      'isVerified': false,
    },
    {
      'name': 'Fidget Sensory Ring',
      'seller': 'Sanduni\'s Crafts',
      'price': 'Rs. 450',
      'rating': 4.6,
      'reviews': 31,
      'tag': 'Sensory',
      'altText': 'Small silicone ring with textured surface for tactile fidgeting',
      'isVerified': true,
    },
    {
      'name': 'Wheelchair Lap Tray',
      'seller': 'MobilityPlus SL',
      'price': 'Rs. 3,800',
      'rating': 4.9,
      'reviews': 12,
      'tag': 'Mobility',
      'altText': 'Adjustable wooden lap tray that attaches to wheelchair armrests',
      'isVerified': true,
    },
    {
      'name': 'Visual Timer (Large)',
      'seller': 'Inclusive Tools LK',
      'price': 'Rs. 1,900',
      'rating': 4.3,
      'reviews': 28,
      'tag': 'Sensory',
      'altText': 'Large round visual timer with colour-coded time display, no audio alarm',
      'isVerified': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products
        .where((p) => p['tag'] == _selectedCategory)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5C5A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AccessiTrade',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Semantics(
            label: 'Notifications',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ),
          Semantics(
            label: 'Profile',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar + voice button
          Container(
            color: const Color(0xFF1A5C5A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Search products text input',
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search accessible products...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Voice search button — large for Nimal (Fitts' Law)
                Semantics(
                  label: 'Activate voice search',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic, size: 64, color: Color(0xFF1A5C5A)),
                              SizedBox(height: 16),
                              Text('Listening...',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Speak your product search',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: const Icon(Icons.mic, color: Color(0xFF1A5C5A), size: 26),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Semantics(
                    label: '$cat category filter${isSelected ? ', selected' : ''}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A5C5A)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1A5C5A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Products grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text('No products found',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'Voice search button',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFF1A5C5A),
          icon: const Icon(Icons.mic, color: Colors.white),
          label: const Text('Voice Search',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${product['name']}, ${product['price']}, rated ${product['rating']} stars, seller ${product['seller']}. ${product['altText']}',
      button: true,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.shopping_bag_outlined,
                          size: 48, color: Color(0xFF1A5C5A)),
                    ),
                    if (product['isVerified'])
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Semantics(
                          label: 'Verified accessibility seller',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A5C5A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.white, size: 10),
                                SizedBox(width: 2),
                                Text('Verified',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product['seller'],
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']} (${product['reviews']})',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product['price'],
                      style: const TextStyle(
                        color: Color(0xFF1A5C5A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// updated
// updated
