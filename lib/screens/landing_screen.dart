import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/screens/auth/sign_in_screen.dart';
import 'package:accessitrade/screens/auth/sign_up_screen.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';
import 'package:accessitrade/services/voice_command_service.dart';
import 'package:accessitrade/widgets/voice_fab.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupVoiceCommands();
    });
  }

  void _setupVoiceCommands() {
    final voiceNav = context.read<VoiceNavigationProvider>();
    final accessibility = context.read<AccessibilityProvider>();
    
    // Sync voice enabled setting
    voiceNav.setAccessibilityProvider(accessibility);
    
    voiceNav.setScreen('landing');
    
    // Only announce if voice features are enabled
    if (accessibility.voiceEnabled) {
      voiceNav.announce('Welcome to AccessiTrade. Say sign in or create account to continue.');
    }
    
    voiceNav.registerScreenCommands('landing', [
      VoiceCommand(
        name: 'sign_in',
        pattern: r'^(sign\s*in|login|log\s*in)$',
        description: 'Go to sign in screen',
        action: (context, params) async {
          final voiceNav = context.read<VoiceNavigationProvider>();
          voiceNav.announce('Opening sign in');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        },
      ),
      VoiceCommand(
        name: 'create_account',
        pattern: r'^(create\s*account|sign\s*up|register)$',
        description: 'Go to create account screen',
        action: (context, params) async {
          final voiceNav = context.read<VoiceNavigationProvider>();
          voiceNav.announce('Opening create account');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          );
        },
      ),
    ]);
  }

  @override
  void dispose() {
    try {
      final voiceNav = context.read<VoiceNavigationProvider>();
      voiceNav.unregisterScreenCommands('landing');
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: const VoiceFAB(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Semantics(
                        label: 'AccessiTrade logo for an accessible marketplace',
                        child: Center(
                          child: Image.asset(
                            'assets/accessitrade_logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Shop Easily\nLive Independently',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              Semantics(
                label: 'Create a new account button',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Semantics(
                label: 'Sign in to existing account button',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A5C5A),
                      side: const BorderSide(color: Color(0xFF1A5C5A), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
