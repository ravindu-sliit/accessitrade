import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentStep = 0; // 0=cart, 1=review, 2=address, 3=payment, 4=confirmed

  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Tactile Sensory Ball',
      'seller': 'AccessAbility Store',
      'price': 850,
      'qty': 1,
    },
    {
      'name': 'Fidget Sensory Ring',
      'seller': 'Sanduni\'s Crafts',
      'price': 450,
      'qty': 2,
    },
  ];

  int get _total =>
      _cartItems.fold(0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 4) return _buildConfirmationScreen();
    if (_currentStep > 0) return _buildCheckoutScreen();
    return _buildCartScreen();
  }

  // ── CART SCREEN ──────────────────────────────────────────────
  Widget _buildCartScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5C5A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Semantics(
                        label:
                            '${item['name']} by ${item['seller']}, quantity ${item['qty']}, Rs. ${item['price'] * item['qty']}',
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8)
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Color(0xFF1A5C5A)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(item['seller'],
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Rs. ${item['price'] * item['qty']}',
                                        style: const TextStyle(
                                            color: Color(0xFF1A5C5A),
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              // Qty controls
                              Row(
                                children: [
                                  Semantics(
                                    label: 'Decrease quantity',
                                    button: true,
                                    child: IconButton(
                                      onPressed: () {
                                        if (item['qty'] > 1) {
                                          setState(() => item['qty']--);
                                        } else {
                                          setState(() =>
                                              _cartItems.removeAt(index));
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                      color: const Color(0xFF1A5C5A),
                                    ),
                                  ),
                                  Text('${item['qty']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Semantics(
                                    label: 'Increase quantity',
                                    button: true,
                                    child: IconButton(
                                      onPressed: () =>
                                          setState(() => item['qty']++),
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: const Color(0xFF1A5C5A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Order summary + proceed
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Rs. $_total',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A5C5A))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: 'Proceed to checkout button',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _currentStep = 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A5C5A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                            ),
                            child: const Text('Proceed to Checkout',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── CHECKOUT STEPS SCREEN ────────────────────────────────────
  Widget _buildCheckoutScreen() {
    final steps = ['Review', 'Address', 'Payment', 'Confirm'];
    final stepIndex = _currentStep - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => setState(() => _currentStep--),
          ),
        ),
        title: Text(
          steps[stepIndex],
          style: const TextStyle(
              color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator — calm, no animations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Semantics(
              label:
                  'Checkout step ${stepIndex + 1} of ${steps.length}: ${steps[stepIndex]}',
              child: Row(
                children: List.generate(steps.length, (i) {
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= stepIndex
                                  ? const Color(0xFF1A5C5A)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (i < steps.length - 1)
                          const SizedBox(width: 4),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps
                  .asMap()
                  .entries
                  .map((e) => Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 11,
                          color: e.key <= stepIndex
                              ? const Color(0xFF1A5C5A)
                              : Colors.grey.shade400,
                          fontWeight: e.key == stepIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStepContent(stepIndex),
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(24),
            child: Semantics(
              label: stepIndex < steps.length - 1
                  ? 'Continue to next step button'
                  : 'Place order button',
              button: true,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 4) {
                      setState(() => _currentStep++);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(
                    stepIndex < steps.length - 1 ? 'Continue' : 'Place Order',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int stepIndex) {
    switch (stepIndex) {
      case 0: // Review
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Your Order',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._cartItems.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Qty: ${item['qty']}',
                                style: TextStyle(
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Text('Rs. ${item['price'] * item['qty']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A5C5A))),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rs. $_total',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5C5A))),
              ],
            ),
          ],
        );

      case 1: // Address
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _checkoutField('Full Name', 'Kumari Perera'),
            const SizedBox(height: 12),
            _checkoutField('Address Line 1', 'No. 45, Galle Road'),
            const SizedBox(height: 12),
            _checkoutField('Address Line 2', 'Colombo 03'),
            const SizedBox(height: 12),
            _checkoutField('Phone Number', '+94 77 123 4567'),
            const SizedBox(height: 12),
            _checkoutField('Delivery Notes (optional)',
                'e.g. ground floor, accessible entrance'),
          ],
        );

      case 2: // Payment
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Method',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _paymentOption(Icons.credit_card, 'Credit / Debit Card',
                'Visa, Mastercard', true),
            const SizedBox(height: 10),
            _paymentOption(
                Icons.account_balance, 'Bank Transfer', 'Direct bank payment', false),
            const SizedBox(height: 10),
            _paymentOption(Icons.money, 'Cash on Delivery',
                'Pay when your order arrives', false),
            const SizedBox(height: 20),
            _checkoutField('Card Number', '•••• •••• •••• ••••'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _checkoutField('Expiry', 'MM / YY')),
                const SizedBox(width: 12),
                Expanded(child: _checkoutField('CVV', '•••')),
              ],
            ),
          ],
        );

      case 3: // Confirm
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm Order',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _summaryRow('Items', '${_cartItems.length} items'),
            _summaryRow('Total', 'Rs. $_total'),
            _summaryRow('Delivery to', 'No. 45, Galle Road, Colombo 03'),
            _summaryRow('Payment', 'Visa card ending in ••47'),
            _summaryRow('Est. Delivery', '3-5 business days'),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _checkoutField(String label, String hint) {
    return Semantics(
      label: '$label input field',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
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
                borderSide: const BorderSide(
                    color: Color(0xFF1A5C5A), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(
      IconData icon, String title, String subtitle, bool selected) {
    return Semantics(
      label: '$title payment option${selected ? ', selected' : ''}',
      button: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE0F2F1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF1A5C5A)
                : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFF1A5C5A)
                    : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? const Color(0xFF1A5C5A)
                              : Colors.black87)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF1A5C5A)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── ORDER CONFIRMATION SCREEN ────────────────────────────────
  Widget _buildConfirmationScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Semantics(
                label: 'Order placed successfully',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF1A5C5A), width: 3),
                  ),
                  child: const Icon(Icons.check,
                      size: 52, color: Color(0xFF1A5C5A)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '#AM-2024-0847',
                  style: TextStyle(
                      color: Color(0xFF1A5C5A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you! Your order has been confirmed\nand is being processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              const Text(
                'Est. Delivery: 3–5 business days',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Delivery summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Delivery to:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('No. 45, Galle Road, Colombo 03',
                        style: TextStyle(color: Colors.grey.shade600)),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paid via Visa card',
                            style:
                                TextStyle(color: Colors.grey.shade600)),
                        Text('Rs. $_total',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Track order button
              Semantics(
                label: 'Track your order button',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Track Your Order',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Continue shopping
              Semantics(
                label: 'Continue shopping button',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A5C5A),
                      side: const BorderSide(
                          color: Color(0xFF1A5C5A), width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Text('Continue Shopping',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Need help, contact support link',
                button: true,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Need Help? Contact Support',
                    style: TextStyle(
                      color: Color(0xFF1A5C5A),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
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
