import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/screens/discovery/discovery_screen.dart';
import 'package:accessitrade/screens/seller/seller_dashboard_screen.dart';
import 'package:accessitrade/screens/checkout/cart_screen.dart';
import 'package:accessitrade/screens/community/community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // The 4 main module screens
  final List<Widget> _screens = const [
    DiscoveryScreen(),
    SellerDashboardScreen(),
    CartScreen(),
    CommunityScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      label: 'Discover',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      semanticLabel: 'Product discovery and search',
    ),
    _NavItem(
      label: 'Sell',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      semanticLabel: 'Seller dashboard',
    ),
    _NavItem(
      label: 'Cart',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      semanticLabel: 'Shopping cart and checkout',
    ),
    _NavItem(
      label: 'Community',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      semanticLabel: 'Community trust and custom requests',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Semantics(
        label: 'Main navigation',
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          elevation: 8,
          destinations: _navItems.map((item) {
            return NavigationDestination(
              icon: Semantics(
                label: item.semanticLabel,
                child: Icon(item.icon),
              ),
              selectedIcon: Semantics(
                label: '${item.semanticLabel}, currently selected',
                child: Icon(item.activeIcon),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String semanticLabel;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.semanticLabel,
  });
}
// updated
