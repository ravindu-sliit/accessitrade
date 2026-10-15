import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/models/cart_item.dart';
import 'package:accessitrade/models/order.dart';
import 'package:accessitrade/services/cart_service.dart';
import 'package:accessitrade/services/order_service.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  final _orderService = OrderService();
  int _currentStep = 0; // 0=cart, 1=address, 2=delivery, 3=payment, 4=review, 5=confirmed

  // Checkout form state
  String _deliveryMethod = 'Standard Delivery';
  double _deliveryFee = 0;
  String _paymentMethod = 'Credit / Debit Card';
  String _deliveryAddress = 'No. 45, Flower Road, Colombo 03, Sri Lanka';
  AppOrder? _placedOrder;
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();
    
    return StreamBuilder<List<CartItem>>(
      stream: _cartService.getCartItems(),
      builder: (context, snapshot) {
        final cartItems = snapshot.data ?? [];
        final total = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

        if (_currentStep == 5 && _placedOrder != null) {
          return _buildConfirmationScreen(_placedOrder!);
        }
        if (_currentStep > 0) {
          return _buildCheckoutScreen(cartItems, total);
        }
        return _buildCartScreen(cartItems, total);
      },
    );
  }

  // ── CART SCREEN ──────────────────────────────────────────────
  Widget _buildCartScreen(List<CartItem> cartItems, double total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Semantics(
                        label: '${item.productName} by ${item.sellerName}, quantity ${item.quantity}, Rs. ${item.subtotal.toStringAsFixed(0)}',
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Semantics(
                                label: '${item.productName} product image',
                                child: Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.shopping_bag_outlined,
                                      color: colorScheme.primary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Rs. ${item.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: colorScheme.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Semantics(
                                    label: 'Decrease quantity',
                                    button: true,
                                    child: GestureDetector(
                                      onTap: () => _cartService.updateQuantity(
                                          item.id, item.quantity - 1),
                                      child: Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.remove,
                                            color: colorScheme.primary, size: 16),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  Semantics(
                                    label: 'Increase quantity',
                                    button: true,
                                    child: GestureDetector(
                                      onTap: () => _cartService.updateQuantity(
                                          item.id, item.quantity + 1),
                                      child: Container(
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.add,
                                            color: colorScheme.primary, size: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Semantics(
                                    label: 'Remove ${item.productName} from cart',
                                    button: true,
                                    child: GestureDetector(
                                      onTap: () => _cartService.removeFromCart(item.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red.shade300),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text('Remove',
                                            style: TextStyle(
                                                color: Colors.red.shade400,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
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
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Summary',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(color: Colors.grey.shade600)),
                          Text('Rs. ${total.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Fee', style: TextStyle(color: Colors.grey.shade600)),
                          const Text('FREE',
                              style: TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Rs. ${total.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary)),
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
                            onPressed: cartItems.isEmpty
                                ? null
                                : () => setState(() => _currentStep = 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                            ),
                            child: const Text('Proceed to Checkout',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  // ── CHECKOUT STEPS ────────────────────────────────────────────
  Widget _buildCheckoutScreen(List<CartItem> cartItems, double total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();
    
    final steps = ['Address', 'Delivery', 'Payment', 'Review'];
    final stepIndex = _currentStep - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: colorScheme.primaryContainer, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.primary),
              onPressed: () => setState(() => _currentStep--),
            ),
          ),
        ),
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(steps.length, (i) {
                final done = i < stepIndex;
                final active = i == stepIndex;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: done || active
                                    ? colorScheme.primary
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: done
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : Text('${i + 1}',
                                        style: TextStyle(
                                            color: active ? Colors.white : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(steps[i],
                                style: TextStyle(
                                    fontSize: 10,
                                    color: active
                                        ? colorScheme.primary
                                        : Colors.grey,
                                    fontWeight: active
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ],
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: done
                                ? colorScheme.primary
                                : Colors.grey.shade200,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(stepIndex, cartItems, total),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isPlacingOrder
                    ? null
                    : () async {
                        if (stepIndex < steps.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          // Place order
                          setState(() => _isPlacingOrder = true);
                          try {
                            final order = await _orderService.createOrder(
                              cartItems: cartItems,
                              deliveryAddress: _deliveryAddress,
                              deliveryMethod: _deliveryMethod,
                              deliveryFee: _deliveryFee,
                              paymentMethod: _paymentMethod,
                            );
                            await _cartService.clearCart();
                            setState(() {
                              _placedOrder = order;
                              _currentStep = 5;
                              _isPlacingOrder = false;
                            });
                          } catch (e) {
                            setState(() => _isPlacingOrder = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Order failed: $e'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        stepIndex < steps.length - 1
                            ? 'Continue to ${steps[stepIndex + 1]}'
                            : 'Place Order — Rs. ${(cartItems.fold(0.0, (s, i) => s + i.subtotal) + _deliveryFee).toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStepContent(int stepIndex, List<CartItem> cartItems, double total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (stepIndex) {
      case 0: // Address
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Saved address
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, color: Color(0xFF1A5C5A)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kumari Jayawardena (Home)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('No. 45, Flower Road, Colombo 03, Sri Lanka'),
                        Text('+94 77 123 4567'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: const Text('Add New Address',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        );

      case 1: // Delivery
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...[
              {'label': 'Standard Delivery', 'fee': 0.0, 'desc': 'Takes 5-7 business days'},
              {'label': 'Express Delivery', 'fee': 500.0, 'desc': 'Takes 2-3 business days'},
              {'label': 'Same Day Delivery', 'fee': 1200.0, 'desc': 'Delivered within 24 hours'},
            ].map((option) {
              final selected = _deliveryMethod == option['label'];
              return Semantics(
                label: '${option['label']} option${selected ? ', selected' : ''}',
                button: true,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _deliveryMethod = option['label'] as String;
                    _deliveryFee = option['fee'] as double;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primaryContainer : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected ? colorScheme.primary : Colors.grey.shade200,
                          width: selected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: selected ? colorScheme.primary : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option['label'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(option['desc'] as String,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(
                          (option['fee'] as double) == 0
                              ? 'Free'
                              : 'Rs. ${(option['fee'] as double).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (option['fee'] as double) == 0
                                  ? Colors.green
                                  : const Color(0xFF1A1A1A)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      case 2: // Payment
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['Cash on Delivery (COD)', 'Credit / Debit Card'].map((method) {
              final selected = _paymentMethod == method;
              return Semantics(
                label: '$method payment option${selected ? ', selected' : ''}',
                button: true,
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = method),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primaryContainer : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected ? colorScheme.primary : Colors.grey.shade200,
                          width: selected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: selected ? colorScheme.primary : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(method, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_paymentMethod == 'Credit / Debit Card') ...[
              const SizedBox(height: 16),
              _checkoutField('Card Number', '4512 8472 9102 3847'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _checkoutField('Expiry Date', '12 / 28')),
                  const SizedBox(width: 12),
                  Expanded(child: _checkoutField('CVC', '***')),
                ],
              ),
            ],
            const SizedBox(height: 20),
            // Order summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _summaryRow('Items Subtotal', 'Rs. ${total.toStringAsFixed(0)}'),
                  _summaryRow('Delivery Fee',
                      _deliveryFee == 0 ? 'FREE' : 'Rs. ${_deliveryFee.toStringAsFixed(0)}'),
                  const Divider(),
                  _summaryRow('Total Amount',
                      'Rs. ${(total + _deliveryFee).toStringAsFixed(0)}',
                      bold: true),
                ],
              ),
            ),
          ],
        );

      case 3: // Review
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Your Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _reviewSection('Delivery Address', null, [
              'Kumari Jayawardena',
              _deliveryAddress,
              '+94 77 123 4567',
            ]),
            const SizedBox(height: 10),
            _reviewSection('Delivery Method', null, [_deliveryMethod]),
            const SizedBox(height: 10),
            _reviewSection('Payment Method', null, [_paymentMethod]),
            const SizedBox(height: 16),
            const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...cartItems.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Qty: ${item.quantity} · Rs. ${item.price.toStringAsFixed(0)} each',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('Rs. ${item.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    ],
                  ),
                )),
          ],
        );

      default:
        return const SizedBox();
    }
  }
  Widget _checkoutField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide: BorderSide(color: const Color(0xFF1A5C5A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: bold ? const Color(0xFF1A5C5A) : Colors.black87,
                  fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _reviewSection(String title, String? editLabel, List<String> lines) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500, fontSize: 12)),
              if (editLabel != null)
                TextButton(
                  onPressed: () {},
                  child: Text('Edit', style: TextStyle(color: const Color(0xFF1A5C5A))),
                ),
            ],
          ),
          ...lines.map((l) => Text(l, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
  // ── ORDER CONFIRMATION ────────────────────────────────────────
  Widget _buildConfirmationScreen(AppOrder order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.read<AccessibilityProvider>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 3),
                ),
                child: Icon(Icons.check, size: 52, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed Successfully!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.orderNumber,
                  style: TextStyle(
                      color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you! Your order has been confirmed and is being processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              if (order.estimatedDelivery != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Est. Delivery: ${order.estimatedDelivery!.day}/${order.estimatedDelivery!.month}/${order.estimatedDelivery!.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 24),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(order.deliveryAddress,
                        style: TextStyle(color: Colors.grey.shade600)),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paid via ${order.paymentMethod}',
                            style: TextStyle(color: Colors.grey.shade600)),
                        Text('Rs. ${order.total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track Your Order',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 56,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _currentStep = 0;
                    _placedOrder = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Continue Shopping',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: Text('Need Help? Contact Support',
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}