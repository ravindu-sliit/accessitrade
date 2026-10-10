import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';

class AccessibilityPreferencesScreen extends StatelessWidget {
  const AccessibilityPreferencesScreen({super.key});

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
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Set Up Your Experience',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Text Size
                      _card(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Text Size',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _textSizeChip(
                                  'Aa (Small)', false, accessibility.largeText,
                                  () => accessibility.setLargeText(false)),
                              const SizedBox(width: 8),
                              _textSizeChip(
                                  'Aa (Large)', true, accessibility.largeText,
                                  () => accessibility.setLargeText(true)),
                            ],
                          ),
                        ],
                      )),

                      const SizedBox(height: 12),

                      // Contrast & Theme
                      _card(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contrast & Theme',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _themeChip(
                                context,
                                'Light',
                                Icons.wb_sunny,
                                Colors.grey,
                                !accessibility.highContrast,
                                () => accessibility.setHighContrast(false),
                              ),
                              const SizedBox(width: 8),
                              _themeChip(
                                context,
                                'High Contrast',
                                Icons.circle,
                                Colors.yellow.shade700,
                                accessibility.highContrast,
                                () => accessibility.setHighContrast(true),
                              ),
                            ],
                          ),
                        ],
                      )),

                      const SizedBox(height: 12),

                      _toggleTile(
                        'Reduce Motion',
                        'Turns off sliding layouts and animations',
                        accessibility.reduceMotion,
                        accessibility.setReduceMotion,
                      ),
                      const SizedBox(height: 8),
                      _toggleTile(
                        'Larger Touch Targets',
                        'Increases button sizes for easier tapping',
                        accessibility.largerTargets,
                        accessibility.setLargerTargets,
                      ),
                      const SizedBox(height: 8),
                      _toggleTile(
                        'Voice Navigation',
                        'Enables voice commands, floating microphone button, and auto-read features',
                        accessibility.voiceEnabled,
                        accessibility.setVoiceEnabled,
                      ),
                      const SizedBox(height: 8),
                      _toggleTile(
                        'Text-to-Speech',
                        'Reads aloud product details on Listen button',
                        accessibility.textToSpeech,
                        accessibility.setTextToSpeech,
                      ),

                      const SizedBox(height: 24),

                      // Preview
                      if (accessibility.highContrast || accessibility.largeText)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accessibility.highContrast
                                ? Colors.black
                                : const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(12),
                            border: accessibility.highContrast
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Text(
                            'Preview: This is how text will appear in the app.',
                            style: TextStyle(
                              fontSize: accessibility.largeText ? 18 : 15,
                              color: accessibility.highContrast
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A5C5A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Save Preferences',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A5C5A),
                            side: const BorderSide(
                                color: Color(0xFF1A5C5A), width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Skip for now',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _textSizeChip(String label, bool isLarge, bool currentIsLarge,
      VoidCallback onTap) {
    final selected = isLarge == currentIsLarge;
    return Expanded(
      child: Semantics(
        label: '$label text size${selected ? ', selected' : ''}',
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF1A5C5A)
                  : Colors.transparent,
              border: Border.all(color: const Color(0xFF1A5C5A)),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      selected ? Colors.white : const Color(0xFF1A5C5A),
                  fontWeight: FontWeight.bold,
                  fontSize: isLarge ? 15 : 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeChip(BuildContext context, String label, IconData icon,
      Color iconColor, bool selected, VoidCallback onTap) {
    return Semantics(
      label: '$label theme${selected ? ', selected' : ''}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1A5C5A)
                : Colors.transparent,
            border: Border.all(
                color: selected
                    ? const Color(0xFF1A5C5A)
                    : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Semantics(
            label: '$title toggle, ${value ? 'on' : 'off'}',
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: const Color(0xFF1A5C5A),
            ),
          ),
        ],
      ),
    );
  }
}