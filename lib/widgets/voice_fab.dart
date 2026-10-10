import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';

/// Floating action button for voice commands
class VoiceFAB extends StatelessWidget {
  final VoidCallback? onListeningStart;
  final VoidCallback? onListeningStop;
  
  const VoiceFAB({
    super.key,
    this.onListeningStart,
    this.onListeningStop,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibility, child) {
        // Only show FAB if voice features are enabled
        if (!accessibility.voiceEnabled) {
          return const SizedBox.shrink();
        }
        
        return Consumer<VoiceNavigationProvider>(
          builder: (context, voiceNav, child) {
            final isListening = voiceNav.isListening;
            final isProcessing = voiceNav.isProcessing;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feedback text when listening
                if (isListening || isProcessing || voiceNav.recognizedText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isListening ? Colors.red.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isListening ? Colors.red : const Color(0xFF1A5C5A),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isListening)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        else if (isProcessing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1A5C5A),
                            ),
                          ),
                        if (isListening || isProcessing) const SizedBox(width: 8),
                        Text(
                          isListening
                              ? 'Listening...'
                              : isProcessing
                                  ? 'Processing...'
                                  : voiceNav.recognizedText,
                          style: TextStyle(
                            color: isListening ? Colors.red : const Color(0xFF1A5C5A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Main FAB with tap-and-hold
                Semantics(
                  label: isListening
                      ? 'Release to stop listening'
                      : 'Hold to speak voice command',
                  button: true,
                  child: GestureDetector(
                    onLongPressStart: (_) async {
                      if (!isListening) {
                        onListeningStart?.call();
                        await voiceNav.startListening(context);
                      }
                    },
                    onLongPressEnd: (_) async {
                      if (isListening) {
                        await voiceNav.stopListening();
                        onListeningStop?.call();
                      }
                    },
                    onTap: () async {
                      // Also support single tap to toggle
                      if (isListening) {
                        await voiceNav.stopListening();
                        onListeningStop?.call();
                      } else {
                        onListeningStart?.call();
                        await voiceNav.startListening(context);
                      }
                    },
                    child: FloatingActionButton.large(
                      heroTag: 'voice_fab',
                      onPressed: null, // Handled by GestureDetector
                      backgroundColor: isListening ? Colors.red : const Color(0xFF1A5C5A),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isListening ? Icons.stop : Icons.mic,
                          key: ValueKey(isListening),
                          color: Colors.white,
                          size: 36, // Increased from 28
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Extended FAB with label for prominent placement
class VoiceFABExtended extends StatelessWidget {
  final String label;
  
  const VoiceFABExtended({
    super.key,
    this.label = 'Voice',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibility, child) {
        // Only show FAB if voice features are enabled
        if (!accessibility.voiceEnabled) {
          return const SizedBox.shrink();
        }
        
        return Consumer<VoiceNavigationProvider>(
          builder: (context, voiceNav, child) {
            final isListening = voiceNav.isListening;
            
            return Semantics(
              label: isListening
                  ? 'Stop voice command'
                  : 'Start voice command',
              button: true,
              child: FloatingActionButton.extended(
                heroTag: 'voice_fab_extended',
                onPressed: () async {
                  if (isListening) {
                    await voiceNav.stopListening();
                  } else {
                    await voiceNav.startListening(context);
                  }
                },
                backgroundColor: isListening ? Colors.red : const Color(0xFF1A5C5A),
                icon: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
                label: Text(
                  isListening ? 'Listening...' : label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
