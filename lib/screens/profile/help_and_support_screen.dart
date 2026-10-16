import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final _messageCtrl = TextEditingController();
  int? _expandedFaq;

  static const _faqs = [
    {
      'q': 'How do I place an order?',
      'a':
          'Browse products on the Discover tab, tap a product to view details, then tap "Add to Cart". When ready, go to Cart and proceed to checkout. You can pay by card or cash on delivery.',
    },
    {
      'q': 'How do I filter products for my accessibility needs?',
      'a':
          'On the Discover tab, use the accessibility filter chips at the top (Tactile, Sensory, Mobility, Visual). You can also tap the filter icon to choose specific accessibility categories.',
    },
    {
      'q': 'How does voice search work?',
      'a':
          'Tap the microphone button on the Discover tab. Speak your product query clearly. The app will transcribe your speech and search for matching products automatically.',
    },
    {
      'q': 'How do I become a seller?',
      'a':
          'Register a new account and select "Seller" as your account type. After registration, you\'ll have access to the Seller Dashboard where you can list products, manage inventory and track orders.',
    },
    {
      'q': 'How do I track my order?',
      'a':
          'Go to Profile → Order History. Tap any order to see its current status, tracking number and estimated delivery date. You\'ll also receive notifications when your order status changes.',
    },
    {
      'q': 'Can I change my accessibility settings?',
      'a':
          'Yes! Go to Profile → Accessibility Settings. You can adjust font size, enable high contrast mode, choose a larger UI layout, and configure text-to-speech preferences.',
    },
    {
      'q': 'How do I return a product?',
      'a':
          'Contact the seller directly through the product page or raise a request via Profile → Request Product. Our support team will assist with disputes and returns within 7 days of delivery.',
    },
    {
      'q': 'Is my payment information secure?',
      'a':
          'Yes. We use industry-standard encryption. We never store full card numbers — only the last 4 digits are saved as a reference. All transactions are processed securely.',
    },
  ];

  void _submitMessage() {
    if (_messageCtrl.text.trim().isEmpty) return;
    _messageCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Message sent! We\'ll respond within 24 hours.'),
        backgroundColor: Color(0xFF1A5C5A),
      ),
    );
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
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
        title: Text('Help & Support',
            style: TextStyle(
                fontSize: accessibility.bodyFontSize + 2,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact options
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Need help?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Our accessibility-trained support team is here for you',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _contactButton(
                        Icons.chat_outlined, 'Live Chat', Colors.white),
                    const SizedBox(width: 12),
                    _contactButton(
                        Icons.phone_outlined, '0117-200-300', Colors.white),
                    const SizedBox(width: 12),
                    _contactButton(
                        Icons.email_outlined, 'Email', Colors.white),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick links
          Text('Quick Help',
              style: TextStyle(
                  fontSize: accessibility.bodyFontSize + 2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _quickLink(Icons.local_shipping_outlined, 'Track My Order',
                    'Check delivery status', colorScheme.primary),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _quickLink(Icons.replay_outlined, 'Return & Refund',
                    'Start a return request', Colors.orange),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _quickLink(Icons.report_problem_outlined, 'Report an Issue',
                    'Product or seller complaint', Colors.red),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _quickLink(Icons.accessible_outlined, 'Accessibility Help',
                    'Assistance for PWD users', Colors.teal),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // FAQ
          Text('Frequently Asked Questions',
              style: TextStyle(
                  fontSize: accessibility.bodyFontSize + 2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: _faqs.asMap().entries.map((entry) {
                final i = entry.key;
                final faq = entry.value;
                final isExpanded = _expandedFaq == i;
                final isLast = i == _faqs.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () =>
                          setState(() => _expandedFaq = isExpanded ? null : i),
                      borderRadius: BorderRadius.vertical(
                        top: i == 0 ? const Radius.circular(16) : Radius.zero,
                        bottom: isLast && !isExpanded
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(faq['q']!,
                                  style: TextStyle(
                                      fontSize: accessibility.bodyFontSize,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        color: Colors.grey.shade50,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['a']!,
                            style: TextStyle(
                                fontSize: accessibility.smallFontSize,
                                color: Colors.grey.shade700,
                                height: 1.6)),
                      ),
                    if (!isLast)
                      Divider(height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Colors.grey.shade200),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Send message
          Text('Send Us a Message',
              style: TextStyle(
                  fontSize: accessibility.bodyFontSize + 2,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Semantics(
                  label: 'Message input field',
                  child: TextField(
                    controller: _messageCtrl,
                    maxLines: 4,
                    style: TextStyle(fontSize: accessibility.bodyFontSize),
                    decoration: InputDecoration(
                      hintText:
                          'Describe your issue or question...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1A5C5A), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Semantics(
                    label: 'Send message button',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: _submitMessage,
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: Text('Send Message',
                          style: TextStyle(
                              fontSize: accessibility.bodyFontSize,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _contactButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Semantics(
        label: '$label contact option',
        button: true,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(color: color, fontSize: 11),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickLink(
      IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      onTap: () {},
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
