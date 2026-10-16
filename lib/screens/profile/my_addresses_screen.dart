import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final _db = FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Map<String, String>>> _addressStream() {
    if (_userId == null) return Stream.value([]);
    return _db.collection('users').doc(_userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data()!;
      return List<Map<String, String>>.from(
        (data['addresses'] ?? []).map((a) => Map<String, String>.from(a)),
      );
    });
  }

  Future<void> _saveAddresses(List<Map<String, String>> addresses) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).update({'addresses': addresses});
  }

  void _showAddressSheet({Map<String, String>? existing, int? index}) {
    final labelCtrl =
        TextEditingController(text: existing?['label'] ?? '');
    final lineCtrl =
        TextEditingController(text: existing?['line'] ?? '');
    final cityCtrl =
        TextEditingController(text: existing?['city'] ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    index == null ? 'Add New Address' : 'Edit Address',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _sheetField(labelCtrl, 'Label', 'e.g. Home, Work, Parents',
                  required: true),
              const SizedBox(height: 12),
              _sheetField(lineCtrl, 'Street Address',
                  'e.g. 45/B, Galle Road, Colombo 03',
                  required: true),
              const SizedBox(height: 12),
              _sheetField(cityCtrl, 'City / District', 'e.g. Colombo'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final newAddr = {
                      'label': labelCtrl.text.trim(),
                      'line': lineCtrl.text.trim(),
                      'city': cityCtrl.text.trim(),
                    };
                    final addresses = await _getAddresses();
                    if (index != null) {
                      addresses[index] = newAddr;
                    } else {
                      addresses.add(newAddr);
                    }
                    await _saveAddresses(addresses);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(index == null ? 'Add Address' : 'Save Changes',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, String hint,
      {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: required
              ? (v) => v == null || v.isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ],
    );
  }

  Future<List<Map<String, String>>> _getAddresses() async {
    if (_userId == null) return [];
    final doc = await _db.collection('users').doc(_userId).get();
    if (!doc.exists) return [];
    return List<Map<String, String>>.from(
        (doc.data()!['addresses'] ?? [])
            .map((a) => Map<String, String>.from(a)));
  }

  Future<void> _deleteAddress(int index) async {
    final addresses = await _getAddresses();
    addresses.removeAt(index);
    await _saveAddresses(addresses);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accessibility = context.watch<AccessibilityProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Addresses',
            style: TextStyle(
                fontSize: accessibility.bodyFontSize + 2,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressSheet(),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: StreamBuilder<List<Map<String, String>>>(
        stream: _addressStream(),
        builder: (context, snapshot) {
          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No saved addresses',
                      style: TextStyle(
                          fontSize: accessibility.bodyFontSize,
                          color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Add your delivery addresses here',
                      style: TextStyle(
                          fontSize: accessibility.smallFontSize,
                          color: Colors.grey.shade400)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              final isFirst = index == 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFirst
                        ? colorScheme.primary
                        : Colors.grey.shade200,
                    width: isFirst ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isFirst
                          ? colorScheme.primaryContainer
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      addr['label']?.toLowerCase().contains('work') == true
                          ? Icons.work_outline
                          : Icons.home_outlined,
                      color: isFirst
                          ? colorScheme.primary
                          : Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(addr['label'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: accessibility.bodyFontSize)),
                      if (isFirst) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Default',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [addr['line'], addr['city']]
                          .where((s) => s != null && s!.isNotEmpty)
                          .join(', '),
                      style: TextStyle(
                          fontSize: accessibility.smallFontSize,
                          color: Colors.grey.shade600),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showAddressSheet(existing: addr, index: index);
                      } else if (val == 'delete') {
                        _deleteAddress(index);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
