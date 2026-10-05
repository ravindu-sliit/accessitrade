import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/models/app_user.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/screens/profile/accessibility_preferences_screen.dart';
import 'package:accessitrade/screens/auth/sign_in_screen.dart';
import 'package:accessitrade/services/user_service.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Profile')),
      body: StreamBuilder<AppUser?>(
        stream: UserService().getCurrentUserStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final name = user?.name.isNotEmpty == true
              ? user!.name
              : firebaseUser?.displayName ?? 'Seller';
          final email = user?.email.isNotEmpty == true
              ? user!.email
              : firebaseUser?.email ?? '';
          final initials =
              user?.initials ?? (name.isNotEmpty ? name[0].toUpperCase() : '?');

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: accessibility.titleFontSize - 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(color: Colors.grey.shade600)),
                    if (user?.phone.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(user!.phone),
                    ],
                    const SizedBox(height: 10),
                    Chip(
                      avatar: const Icon(Icons.storefront_outlined, size: 18),
                      label: Text(
                        user?.userType == 'seller'
                            ? 'Seller account'
                            : 'Seller Centre',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileSection(
                icon: Icons.person_outline,
                title: 'Seller Details',
                onTap: () => _showSellerDetails(context, user, name, email),
              ),
              _ProfileSection(
                icon: Icons.accessible,
                title: 'Accessibility Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccessibilityPreferencesScreen(),
                    ),
                  );
                },
              ),
              _ProfileSection(
                icon: Icons.logout_outlined,
                title: 'Log Out',
                onTap: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSellerDetails(
    BuildContext context,
    AppUser? user,
    String name,
    String email,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seller Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seller Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editSellerDetails(context, user, name);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              _DetailRow(label: 'Name', value: name),
              _DetailRow(label: 'Email', value: email),
              _DetailRow(label: 'Phone', value: user?.phone ?? 'Not provided'),
              _DetailRow(
                label: 'Account type',
                value: user?.userType ?? 'seller',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editSellerDetails(
    BuildContext context,
    AppUser? user,
    String currentName,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Seller Details'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Seller name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a seller name'
                    : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number'),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email and account type are managed by your account.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await UserService().updateProfile(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
