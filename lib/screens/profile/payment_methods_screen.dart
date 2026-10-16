import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Simulated saved payment methods (in a real app stored in Firestore)
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'visa',
      'last4': '4242',
      'expiry': '12/27',
      'holder': 'Ravindu Sooriyaarachchi',
      'isDefault': true,
    },
  ];

  void _showAddCardSheet() {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
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
                  const Text('Add Payment Method',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Your card details are stored securely',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 16),
              _sheetField(nameCtrl, 'Cardholder Name', 'As on your card',
                  required: true),
              const SizedBox(height: 12),
              _sheetField(numberCtrl, 'Card Number', '1234 5678 9012 3456',
                  keyboardType: TextInputType.number,
                  required: true,
                  validator: (v) {
                    if (v == null || v.replaceAll(' ', '').length < 16) {
                      return 'Enter valid card number';
                    }
                    return null;
                  }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _sheetField(
                        expiryCtrl, 'Expiry', 'MM/YY',
                        required: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sheetField(
                        cvvCtrl, 'CVV', '123',
                        keyboardType: TextInputType.number,
                        required: true),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final num = numberCtrl.text.replaceAll(' ', '');
                    final last4 = num.length >= 4
                        ? num.substring(num.length - 4)
                        : '????';
                    final type = num.startsWith('4') ? 'visa' : 'mastercard';
                    setState(() {
                      _paymentMethods.add({
                        'type': type,
                        'last4': last4,
                        'expiry': expiryCtrl.text.trim(),
                        'holder': nameCtrl.text.trim(),
                        'isDefault': _paymentMethods.isEmpty,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Card added successfully'),
                        backgroundColor: Color(0xFF1A5C5A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Add Card',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl, String label, String hint, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
          keyboardType: keyboardType,
          validator: validator ??
              (required
                  ? (v) => v == null || v.isEmpty ? 'Required' : null
                  : null),
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

  IconData _cardIcon(String type) {
    switch (type) {
      case 'visa': return Icons.credit_card;
      case 'mastercard': return Icons.credit_card;
      default: return Icons.payment;
    }
  }

  Color _cardColor(String type) {
    switch (type) {
      case 'visa': return const Color(0xFF1A1F71);
      case 'mastercard': return const Color(0xFFEB001B);
      default: return Colors.grey;
    }
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
        title: Text('Payment Methods',
            style: TextStyle(
                fontSize: accessibility.bodyFontSize + 2,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardSheet,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: _paymentMethods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No payment methods saved',
                      style: TextStyle(
                          fontSize: accessibility.bodyFontSize,
                          color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Security note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 16, color: Colors.teal.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your payment info is encrypted and stored securely. We never store your full card number.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.teal.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ..._paymentMethods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final method = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _cardColor(method['type']),
                          _cardColor(method['type']).withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _cardColor(method['type']).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                method['type'].toString().toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 2),
                              ),
                              Row(
                                children: [
                                  if (method['isDefault'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                            alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text('Default',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10)),
                                    ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onSelected: (val) {
                                      if (val == 'default') {
                                        setState(() {
                                          for (var m in _paymentMethods) {
                                            m['isDefault'] = false;
                                          }
                                          _paymentMethods[index]
                                              ['isDefault'] = true;
                                        });
                                      } else if (val == 'remove') {
                                        setState(() =>
                                            _paymentMethods
                                                .removeAt(index));
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                          value: 'default',
                                          child: Text('Set as Default')),
                                      const PopupMenuItem(
                                          value: 'remove',
                                          child: Text('Remove',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '•••• •••• •••• ${method['last4']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('CARDHOLDER',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          letterSpacing: 1)),
                                  Text(method['holder'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('EXPIRES',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          letterSpacing: 1)),
                                  Text(method['expiry'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),
                // Other payment options
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _paymentOption(
                          Icons.account_balance_outlined,
                          'Bank Transfer',
                          'Direct bank payment',
                          Colors.blue),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _paymentOption(
                          Icons.payment_outlined,
                          'Cash on Delivery',
                          'Pay when you receive',
                          Colors.green),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _paymentOption(
      IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
