import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/screens/home/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibility, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 16),
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.accessibility_new,
                                size: 48, color: Color(0xFF1A5C5A)),
                            SizedBox(height: 12),
                            Text(
                              'Set Up Accessibility',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A5C5A)),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Personalise AccessMart for your needs. These settings help you navigate the app independently.',
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text Size
                      _sectionCard(
                        'Text Size',
                        Row(
                          children: [
                            Expanded(
                              child: _sizeChip('Aa (Small)', false,
                                  accessibility.largeText,
                                  () => accessibility.setLargeText(false)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _sizeChip('Aa (Large)', true,
                                  accessibility.largeText,
                                  () => accessibility.setLargeText(true)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Voice Search
                      _toggleCard(
                        'Voice Search',
                        'Search for products by speaking instead of typing',
                        Icons.mic,
                        accessibility.voiceEnabled,
                        accessibility.setVoiceEnabled,
                      ),
                      const SizedBox(height: 8),

                      // Text-to-Speech
                      _toggleCard(
                        'Text-to-Speech',
                        'Hear product details read aloud when you tap Listen',
                        Icons.volume_up,
                        accessibility.textToSpeech,
                        accessibility.setTextToSpeech,
                      ),
                      const SizedBox(height: 8),

                      // High Contrast
                      _toggleCard(
                        'High Contrast',
                        'Use black and white colours for better visibility',
                        Icons.contrast,
                        accessibility.highContrast,
                        accessibility.setHighContrast,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Semantics(
                          label: 'Continue to app button',
                          button: true,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A5C5A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                            ),
                            child: Text(
                              'Continue to App',
                              style: TextStyle(
                                  fontSize: accessibility.bodyFontSize + 2,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Semantics(
                          label: 'Skip accessibility setup button',
                          button: true,
                          child: TextButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            ),
                            child: const Text(
                              'Skip for now',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _sizeChip(String label, bool isLarge, bool currentIsLarge,
      VoidCallback onTap) {
    final selected = isLarge == currentIsLarge;
    return Semantics(
      label: '$label text size${selected ? ', selected' : ''}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1A5C5A) : Colors.transparent,
            border: Border.all(color: const Color(0xFF1A5C5A)),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF1A5C5A),
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 15 : 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleCard(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged) {
    return Semantics(
      label: '$title toggle, ${value ? 'enabled' : 'disabled'}',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: value ? const Color(0xFFE0F2F1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value
                  ? const Color(0xFF1A5C5A)
                  : Colors.grey.shade200,
              width: value ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: value
                      ? const Color(0xFF1A5C5A)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: value ? Colors.white : Colors.grey,
                    size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: const Color(0xFF1A5C5A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}