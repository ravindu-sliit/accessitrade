import 'package:flutter/material.dart';
import 'package:accessitrade/screens/discovery/home_tab.dart';
import 'package:accessitrade/screens/discovery/categories_screen.dart';
import 'package:accessitrade/screens/checkout/cart_screen.dart';
import 'package:accessitrade/screens/profile/profile_screen.dart';
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
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
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