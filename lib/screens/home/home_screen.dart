import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';
import 'package:accessitrade/widgets/voice_fab.dart';
import 'package:accessitrade/screens/discovery/home_tab.dart';
import 'package:accessitrade/screens/discovery/categories_screen.dart';
import 'package:accessitrade/screens/community/community_screen.dart';
import 'package:accessitrade/screens/checkout/cart_screen.dart';
import 'package:accessitrade/screens/profile/profile_screen.dart';
import 'package:accessitrade/screens/discovery/search_results_screen.dart';
import 'package:accessitrade/services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _cartService = CartService();

  final List<Widget> _screens = const [
    HomeTab(),
    CategoriesScreen(),
    CommunityScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  final List<String> _screenNames = const ['Home', 'Categories', 'Community', 'Cart', 'Profile'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupVoiceNavigation();
    });
  }

  void _setupVoiceNavigation() {
    final voiceNav = context.read<VoiceNavigationProvider>();
    final accessibility = context.read<AccessibilityProvider>();
    
    // Sync voice enabled setting
    voiceNav.setAccessibilityProvider(accessibility);
    
    voiceNav.onTabChange = (tabIndex) {
      if (tabIndex != _currentIndex) {
        setState(() {
          _currentIndex = tabIndex;
        });
        voiceNav.announce('Switched to ${_screenNames[tabIndex]}');
      }
    };

    // Add search callback
    voiceNav.onSearch = (query) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(query: query),
        ),
      );
    };

    voiceNav.setScreen('home');
    
    // Only announce if voice features are enabled
    if (accessibility.voiceEnabled) {
      voiceNav.announce('Home screen. Tap microphone or say help for commands.');
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    final voiceNav = context.read<VoiceNavigationProvider>();
    final accessibility = context.read<AccessibilityProvider>();
    voiceNav.setScreen(_screenNames[index].toLowerCase());
    if (accessibility.voiceEnabled) {
      voiceNav.announce('Switched to ${_screenNames[index]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: const VoiceFAB(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: colorScheme.primary),
            label: 'Home',
            tooltip: 'Home tab',
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: colorScheme.primary),
            label: 'Categories',
            tooltip: 'Browse categories',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: colorScheme.primary),
            label: 'Community',
            tooltip: 'Community hub',
          ),
          NavigationDestination(
            icon: StreamBuilder<int>(
              stream: _cartService.getCartCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Semantics(
                  label: count > 0 ? 'Cart, $count items' : 'Cart, empty',
                  child: count > 0 
                    ? Badge(
                        label: Text('$count'),
                        child: const Icon(Icons.shopping_cart_outlined),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            selectedIcon: StreamBuilder<int>(
              stream: _cartService.getCartCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Semantics(
                  label: count > 0 ? 'Cart, $count items' : 'Cart, empty',
                  child: count > 0 
                    ? Badge(
                        label: Text('$count'),
                        child: Icon(Icons.shopping_cart, color: colorScheme.primary),
                      )
                    : Icon(Icons.shopping_cart, color: colorScheme.primary),
                );
              },
            ),
            label: 'Cart',
            tooltip: 'Shopping cart',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: colorScheme.primary),
            label: 'Profile',
            tooltip: 'User profile',
          ),
        ],
      ),
    );
  }
}
