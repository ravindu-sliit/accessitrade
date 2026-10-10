import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';
import 'package:accessitrade/services/auth_service.dart';
import 'package:accessitrade/services/voice_command_service.dart';
import 'package:accessitrade/screens/auth/forgot_password_screen.dart';
import 'package:accessitrade/screens/home/home_screen.dart';
import 'package:accessitrade/screens/seller/seller_dashboard_screen.dart';
import 'package:accessitrade/widgets/voice_fab.dart';

enum _VoiceAuthStep { idle, waitingEmail, waitingPassword }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  _VoiceAuthStep _voiceStep = _VoiceAuthStep.idle;

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
    
    voiceNav.setScreen('sign_in');
    voiceNav.announce('Sign in screen. Hold the microphone and say sign in to start.');
    
    voiceNav.registerScreenCommands('sign_in', [
      VoiceCommand(
        name: 'sign_in_flow',
        pattern: r'^(.+)$',  // Catch all - but we check state inside
        description: 'Handle voice sign in flow',
        action: (context, params) async {
          if (params == null || params.isEmpty) return;
          _processVoiceInput(params);
        },
      ),
    ]);
  }

  void _processVoiceInput(String input) {
    final voiceNav = context.read<VoiceNavigationProvider>();
    final lowerInput = input.toLowerCase().trim();
    
    debugPrint('🎤 SIGNIN: Processing "$input" in step: $_voiceStep');
    
    switch (_voiceStep) {
      case _VoiceAuthStep.idle:
        // Check if user wants to start sign in
        if (lowerInput.contains('sign') && lowerInput.contains('in') ||
            lowerInput.contains('login') ||
            lowerInput == 'log in') {
          setState(() {
            _voiceStep = _VoiceAuthStep.waitingEmail;
            _emailController.clear();
            _passwordController.clear();
            _errorMessage = null;
          });
          voiceNav.announce('Please say your email address. For example: john at gmail dot com');
        } else if (lowerInput.contains('back')) {
          Navigator.pop(context);
        }
        break;
        
      case _VoiceAuthStep.waitingEmail:
        if (lowerInput.contains('cancel') || lowerInput.contains('stop')) {
          setState(() => _voiceStep = _VoiceAuthStep.idle);
          voiceNav.announce('Cancelled. Say sign in to try again.');
          return;
        }
        // Convert spoken email
        final email = lowerInput
            .replaceAll(' at ', '@')
            .replaceAll(' dot ', '.')
            .replaceAll(' ', '');
        setState(() {
          _emailController.text = email;
          _voiceStep = _VoiceAuthStep.waitingPassword;
        });
        voiceNav.announce('Email is $email. Now please say your password.');
        break;
        
      case _VoiceAuthStep.waitingPassword:
        if (lowerInput.contains('cancel') || lowerInput.contains('stop')) {
          setState(() => _voiceStep = _VoiceAuthStep.idle);
          voiceNav.announce('Cancelled. Say sign in to try again.');
          return;
        }
        // Password - just remove spaces
        final password = input.replaceAll(' ', '');
        setState(() {
          _passwordController.text = password;
          _voiceStep = _VoiceAuthStep.idle;
        });
        voiceNav.announce('Password received. Signing in now.');
        _voiceSignIn();
        break;
    }
  }

  Future<void> _voiceSignIn() async {
    final voiceNav = context.read<VoiceNavigationProvider>();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final profile = credential?.user == null
          ? null
          : await _authService.getUserProfile(credential!.user!.uid);
      
      await voiceNav.announce('Sign in successful. Welcome back!');
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => profile?['userType'] == 'seller'
                ? const SellerDashboardScreen()
                : const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in failed. Please try again.';
        _voiceStep = _VoiceAuthStep.idle;
      });
      voiceNav.announce('Sign in failed. The email or password may be incorrect. Say sign in to try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      final voiceNav = context.read<VoiceNavigationProvider>();
      voiceNav.unregisterScreenCommands('sign_in');
    } catch (_) {}
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final profile = credential?.user == null
          ? null
          : await _authService.getUserProfile(credential!.user!.uid);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => profile?['userType'] == 'seller'
                ? const SellerDashboardScreen()
                : const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessibility = context.watch<AccessibilityProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: const VoiceFAB(),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: accessibility.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize: accessibility.bodyFontSize,
                    color: Colors.grey,
                  ),
                ),

                // Voice auth status indicator
                if (_voiceStep != _VoiceAuthStep.idle)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A5C5A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Color(0xFF1A5C5A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _voiceStep == _VoiceAuthStep.waitingEmail
                                ? 'Voice Sign In: Say your email address'
                                : 'Voice Sign In: Say your password',
                            style: const TextStyle(
                              color: Color(0xFF1A5C5A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _voiceStep = _VoiceAuthStep.idle;
                              _emailController.clear();
                              _passwordController.clear();
                            });
                            final voiceNav = context.read<VoiceNavigationProvider>();
                            voiceNav.announce('Voice sign in cancelled');
                          },
                          child: const Icon(Icons.close, color: Color(0xFF1A5C5A), size: 20),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Email
                _buildLabel('Email Address', accessibility, theme),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Email address input',
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      colorScheme,
                      accessibility,
                      'kumari@accessmarket.lk',
                    ).copyWith(labelText: 'Email Address'),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter your email';
                      if (!v.contains('@'))
                        return 'Enter a valid email address';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Password
                _buildLabel('Password', accessibility, theme),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Password input',
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration:
                        _inputDecoration(
                          colorScheme,
                          accessibility,
                          '••••••••',
                        ).copyWith(
                          labelText: 'Password',
                          suffixIcon: Semantics(
                            label: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            button: true,
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter your password'
                        : null,
                  ),
                ),

                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    label: 'Forgot password link',
                    button: true,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Error message
                if (_errorMessage != null)
                  Semantics(
                    liveRegion: true,
                    label: 'Error: $_errorMessage',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: accessibility.bodyFontSize - 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Sign in button
                Semantics(
                  label: 'Sign in button',
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: accessibility.bodyFontSize + 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign up link
                Center(
                  child: Semantics(
                    label: "Don't have an account, Create Account link",
                    button: true,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account?  ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: accessibility.bodyFontSize,
                          ),
                          children: [
                            TextSpan(
                              text: 'Create Account',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: accessibility.bodyFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                // Google & Apple
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Continue with Google button',
                        button: true,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 22,
                            color: Colors.black87,
                          ),
                          label: Text(
                            'Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: accessibility.bodyFontSize,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: 'Continue with Apple button',
                        button: true,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.apple,
                            size: 22,
                            color: Colors.black87,
                          ),
                          label: Text(
                            'Apple',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: accessibility.bodyFontSize,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text,
    AccessibilityProvider accessibility,
    ThemeData theme,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontSize: accessibility.bodyFontSize,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme colorScheme,
    AccessibilityProvider accessibility,
    String hint,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    );
  }
}
