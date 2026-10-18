import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/models/app_user.dart';
import 'package:accessitrade/services/user_service.dart';
import 'package:accessitrade/screens/profile/my_orders_screen.dart';
import 'package:accessitrade/screens/profile/wishlist_screen.dart';
import 'package:accessitrade/screens/profile/notifications_screen.dart';
import 'package:accessitrade/screens/profile/accessibility_preferences_screen.dart';
import 'package:accessitrade/screens/profile/personal_information_screen.dart';
import 'package:accessitrade/screens/profile/my_addresses_screen.dart';
import 'package:accessitrade/screens/profile/payment_methods_screen.dart';
import 'package:accessitrade/screens/profile/help_and_support_screen.dart';
import 'package:accessitrade/screens/seller/seller_dashboard_screen.dart';
import 'package:accessitrade/screens/profile/my_requested_products_screen.dart';
import 'package:accessitrade/screens/auth/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.watch<AccessibilityProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<AppUser?>(
          stream: UserService().getCurrentUserStream(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final firebaseUser = FirebaseAuth.instance.currentUser;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: accessibility.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Profile header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                user?.initials ??
                                    firebaseUser?.email
                                        ?.substring(0, 2)
                                        .toUpperCase() ??
                                    '?',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: accessibility.bodyFontSize + 5,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? firebaseUser?.displayName ?? 'User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: accessibility.bodyFontSize,
                              ),
                            ),
                            Text(
                              user?.email ?? firebaseUser?.email ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: accessibility.smallFontSize,
                              ),
                            ),
                            if (user?.phone != null && user!.phone.isNotEmpty)
                              Text(
                                user.phone,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: accessibility.smallFontSize,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.person_outline,
                  'Personal Information',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.accessible,
                  'Accessibility Settings',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccessibilityPreferencesScreen(),
                      ),
                    );
                  },
                  highlight: true,
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.location_on_outlined,
                  'My Addresses',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyAddressesScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.credit_card_outlined,
                  'Payment Methods',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.shopping_bag_outlined,
                  'Order History',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.favorite_outline,
                  'Wishlist',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.assignment_outlined,
                  'My Requested Products',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyRequestedProductsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.notifications_outlined,
                  'Notification Preferences',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (user?.userType == 'seller')
                  _buildMenuItem(
                    context,
                    theme,
                    colorScheme,
                    accessibility,
                    Icons.storefront_outlined,
                    'Seller Dashboard',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerDashboardScreen(),
                        ),
                      );
                    },
                  ),
                _buildMenuItem(
                  context,
                  theme,
                  colorScheme,
                  accessibility,
                  Icons.help_center_outlined,
                  'Help and Support',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpAndSupportScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      'Sign Out of Account',
                      style: TextStyle(
                        fontSize: accessibility.bodyFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'AccessiTrade App Version 2.4.1 (Accessibility First)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: accessibility.smallFontSize - 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AccessibilityProvider accessibility,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool highlight = false,
  }) {
    return Semantics(
      label: '$label menu item',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: highlight ? colorScheme.primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: highlight ? colorScheme.primary : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: accessibility.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: highlight
                        ? colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
