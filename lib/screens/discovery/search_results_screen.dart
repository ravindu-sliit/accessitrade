import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/models/product.dart';
import 'package:accessitrade/services/product_service.dart';
import 'package:accessitrade/services/cart_service.dart';
import 'package:accessitrade/services/cloudinary_service.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';
import 'package:accessitrade/widgets/voice_fab.dart';
import 'package:accessitrade/screens/discovery/filter_screen.dart';
import 'package:accessitrade/screens/discovery/product_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final String? category;
  final bool fromVoice;

  const SearchResultsScreen({
    super.key,
    required this.query,
    this.category,
    this.fromVoice = false,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _productService = ProductService();
  final _cartService = CartService();
  final FlutterTts _tts = FlutterTts();
  bool _isReading = false;
  int _currentItemIndex = 0;
  List<Product> _currentResults = [];
  bool _hasAnnouncedResults = false;
  VoiceNavigationProvider? _voiceNavProvider;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerVoiceCommands();
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isReading = false);
    });
  }

  Future<void> _readResultsAloud(List<Product> products) async {
    if (products.isEmpty) {
      await _tts.speak('No results found for ${widget.query}');
      return;
    }

    setState(() => _isReading = true);

    final count = products.length;
    final intro = 'Found $count results for ${widget.query}. ';

    // Read first 3 results
    final toRead = products.take(3).toList();
    final items = toRead.asMap().entries.map((e) {
      final i = e.key + 1;
      final p = e.value;
      return 'Result $i: ${p.name}. Price Rs. ${p.price.toStringAsFixed(0)}. Rated ${p.rating} stars.';
    }).join(' ');

    final suffix = count > 3
        ? ' And ${count - 3} more results. Swipe to explore.'
        : ' End of results.';

    await _tts.speak('$intro$items$suffix');
  }

  Future<void> _stopReading() async {
    await _tts.stop();
    setState(() => _isReading = false);
  }

  void _registerVoiceCommands() {
    _voiceNavProvider = context.read<VoiceNavigationProvider>();
    final voiceNav = _voiceNavProvider!;
    final accessibility = context.read<AccessibilityProvider>();
    
    // Sync voice enabled setting
    voiceNav.setAccessibilityProvider(accessibility);
    
    voiceNav.setScreen('search_results');
    voiceNav.voiceService.registerScreenCommands('search_results', {
      'next_item': r'^(next|down|forward).*$',
      'previous_item': r'^(previous|back|up|before).*$',
      'select_item': r'^(select|open|view|details|tap|click|choose).*$',
      'add_to_cart': r'^(add|cart|buy).*$',
      'go_back': r'^(go\s*back|back|return|close|exit)$',
      'read_current': r'^(read|tell|what|describe).*$',
    });
    
    voiceNav.voiceService.onScreenCommand = _handleVoiceCommand;
  }

  void _handleVoiceCommand(String command, String? param) {
    final voiceNav = context.read<VoiceNavigationProvider>();
    final accessibility = context.read<AccessibilityProvider>();
    
    if (!accessibility.voiceEnabled) return;
    
    switch (command) {
      case 'next_item':
        if (_currentResults.isEmpty) return;
        setState(() {
          if (_currentItemIndex < _currentResults.length - 1) {
            _currentItemIndex++;
          } else {
            voiceNav.announce('Last item');
            return;
          }
        });
        _announceCurrentItem(voiceNav);
        break;
      case 'previous_item':
        if (_currentResults.isEmpty) return;
        setState(() {
          if (_currentItemIndex > 0) {
            _currentItemIndex--;
          } else {
            voiceNav.announce('First item');
            return;
          }
        });
        _announceCurrentItem(voiceNav);
        break;
      case 'select_item':
        if (_currentResults.isEmpty) return;
        final product = _currentResults[_currentItemIndex];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
        break;
      case 'add_to_cart':
        if (_currentResults.isEmpty) return;
        _addCurrentToCart();
        break;
      case 'go_back':
        Navigator.pop(context);
        break;
      case 'read_current':
        _announceCurrentItem(voiceNav);
        break;
    }
  }

  void _announceCurrentItem(VoiceNavigationProvider voiceNav) {
    if (_currentResults.isEmpty) {
      voiceNav.announce('No results');
      return;
    }
    final product = _currentResults[_currentItemIndex];
    final itemNum = _currentItemIndex + 1;
    final total = _currentResults.length;
    voiceNav.announce('Item $itemNum of $total. ${product.name}. Rs. ${product.price.toStringAsFixed(0)}. Rated ${product.rating} stars.');
  }

  Future<void> _addCurrentToCart() async {
    if (_currentResults.isEmpty) return;
    final product = _currentResults[_currentItemIndex];
    await _cartService.addToCart(product);
    if (mounted) {
      final voiceNav = context.read<VoiceNavigationProvider>();
      voiceNav.announce('Added ${product.name} to cart');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to cart'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _voiceNavProvider?.voiceService.clearScreenCommands();
    super.dispose();
  }

  /// Compare two product lists by ID to detect actual changes
  bool _listEquals(List<Product> a, List<Product> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accessibility = context.watch<AccessibilityProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: StreamBuilder<List<Product>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                final allProducts = snapshot.data ?? [];
                final results = allProducts.where((p) {
                  final q = widget.query.toLowerCase();
                  final cat = widget.category?.toLowerCase();
                  
                  // If category is specified, filter by category (case-insensitive contains)
                  if (cat != null) {
                    return p.category.toLowerCase().contains(cat) ||
                           cat.contains(p.category.toLowerCase());
                  }
                  
                  // Otherwise search across all text fields
                  return p.name.toLowerCase().contains(q) ||
                         p.category.toLowerCase().contains(q) ||
                         p.description.toLowerCase().contains(q) ||
                         p.altText.toLowerCase().contains(q);
                }).toList();

                // Update results reference for voice navigation (no setState needed here)
                if (!_listEquals(_currentResults, results)) {
                  _currentResults = results;
                  if (_currentItemIndex >= results.length) {
                    _currentItemIndex = 0;
                  }
                  
                  // Use post frame callback only for voice announcements, with proper mounted check
                  if (!_hasAnnouncedResults && results.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _hasAnnouncedResults = true;
                      final voiceNav = context.read<VoiceNavigationProvider>();
                      voiceNav.setScreen('search_results', itemCount: results.length);
                      final accessibility = context.read<AccessibilityProvider>();
                      if (accessibility.voiceEnabled) {
                        voiceNav.announce('Found ${results.length} items for ${widget.query}. Say next or previous to navigate, select to view details.');
                      }
                    });
                  }
                }

                // Auto-read aloud if from voice search and results loaded
                if (widget.fromVoice &&
                    snapshot.connectionState == ConnectionState.active &&
                    results.isNotEmpty &&
                    !_isReading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_isReading) {
                      _readResultsAloud(results);
                    }
                  });
                }

                return Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: colorScheme.primary, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Semantics(
                              label: 'Go back',
                              button: true,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Expanded(
                              child: Text(widget.query,
                                  style: TextStyle(
                                      fontSize: accessibility.bodyFontSize,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Semantics(
                              label: 'Clear search',
                              button: true,
                              child: IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Results count + TTS button + filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${results.length} results found',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: accessibility.smallFontSize),
                          ),
                          const Spacer(),

                          // Listen button — reads results aloud
                          if (widget.fromVoice || accessibility.textToSpeech) ...[  
                            Semantics(
                              label: _isReading
                                  ? 'Stop reading results'
                                  : 'Listen to search results',
                              button: true,
                              child: GestureDetector(
                                onTap: _isReading
                                    ? _stopReading
                                    : () => _readResultsAloud(results),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: _isReading
                                        ? Colors.orange.shade50
                                        : const Color(0xFFE0F2F1),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: _isReading
                                          ? Colors.orange
                                          : colorScheme.primary,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isReading
                                            ? Icons.stop
                                            : Icons.volume_up_outlined,
                                        color: _isReading
                                            ? Colors.orange
                                            : colorScheme.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isReading ? 'Stop' : 'Listen',
                                        style: TextStyle(
                                          color: _isReading
                                              ? Colors.orange
                                              : colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Filter button
                          Semantics(
                            label: 'Filter results button',
                            button: true,
                            child: GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const FilterScreen())),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.tune,
                                        color: colorScheme.primary, size: 16),
                                    const SizedBox(width: 6),
                                    Text('Filter',
                                        style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF1A5C5A)),
                        ),
                      )

                    // No results
                    else if (results.isEmpty)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found for "${widget.query}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: accessibility.bodyFontSize),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try different keywords or browse categories',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )

                    // Results list
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: results.length + 1,
                          itemBuilder: (context, index) {
                            if (index == results.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(
                                          color: colorScheme.primary, width: 2),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32)),
                                    ),
                                    child: const Text('Load More Results',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              );
                            }

                            final product = results[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Semantics(
                                label:
                                    '${product.name}, ${product.price.toStringAsFixed(0)} rupees, rated ${product.rating} stars. ${product.altText}',
                                button: true,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                          product: product),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: index == _currentItemIndex
                                          ? colorScheme.primary.withValues(alpha: 0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: index == _currentItemIndex
                                            ? colorScheme.primary
                                            : Colors.grey.shade200,
                                        width: index == _currentItemIndex ? 2 : 1,
                                      ),
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
                                                  errorBuilder: (context, error, stackTrace) => Container(
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        accessibility.bodyFontSize),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Rs. ${product.price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        accessibility.bodyFontSize),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star,
                                                      color: Colors.amber,
                                                      size: 14),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      '${product.rating} (${product.reviewCount} reviews)',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: accessibility
                                                              .smallFontSize),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Semantics(
                                          label:
                                              'Add ${product.name} to cart',
                                          button: true,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              await _cartService
                                                  .addToCart(product);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Added ${product.name} to cart'),
                                                    backgroundColor:
                                                        colorScheme.primary,
                                                    duration: const Duration(
                                                        seconds: 1),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.add, size: 14),
                                            label: const Text('Add to Cart',
                                                style:
                                                    TextStyle(fontSize: 11)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(32)),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 8),
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
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        // VoiceFAB positioned at bottom-right
        const Positioned(
          right: 16,
          bottom: 16,
          child: VoiceFAB(),
        ),
      ],
    );
  }
}
