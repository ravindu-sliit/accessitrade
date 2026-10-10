import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:accessitrade/services/auth_service.dart';
import 'package:accessitrade/screens/home/home_screen.dart';
import 'package:accessitrade/screens/seller/seller_dashboard_screen.dart';

enum _VoiceLoginStep {
  idle,
  listeningEmail,
  listeningPassword,
  confirming,
  signingIn,
}

class VoiceLoginScreen extends StatefulWidget {
  const VoiceLoginScreen({super.key});

  @override
  State<VoiceLoginScreen> createState() => _VoiceLoginScreenState();
}

class _VoiceLoginScreenState extends State<VoiceLoginScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final AuthService _authService = AuthService();

  _VoiceLoginStep _step = _VoiceLoginStep.idle;
  String _email = '';
  String _password = '';
  String _statusMessage = 'Tap the microphone to start voice sign in';
  String? _errorMessage;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _startVoiceLogin() async {
    if (!_speechAvailable) {
      setState(() {
        _errorMessage = 'Voice recognition not available on this device';
      });
      return;
    }

    setState(() {
      _step = _VoiceLoginStep.listeningEmail;
      _statusMessage = 'Listening for your email address...';
      _errorMessage = null;
    });

    await _speak('Please say your email address');
    await Future.delayed(const Duration(milliseconds: 800));

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final spoken = result.recognizedWords
              .toLowerCase()
              .replaceAll(' at ', '@')
              .replaceAll(' dot ', '.')
              .replaceAll(' ', '');
          setState(() {
            _email = spoken;
            _step = _VoiceLoginStep.listeningPassword;
            _statusMessage = 'Email: $_email\nNow say your password';
          });
          _speech.stop();
          _listenForPassword();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _listenForPassword() async {
    await _speak('Now say your password');
    await Future.delayed(const Duration(milliseconds: 800));

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final spoken = result.recognizedWords.replaceAll(' ', '');
          setState(() {
            _password = spoken;
            _step = _VoiceLoginStep.confirming;
            _statusMessage =
                'Email: $_email\nPassword received.\nTap Sign In to continue or retry.';
          });
          _speech.stop();
          _speak(
            'I heard your credentials. Tap Sign In to continue, or tap Retry to try again.',
          );
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _step = _VoiceLoginStep.signingIn;
      _statusMessage = 'Signing in...';
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signIn(
        email: _email,
        password: _password,
      );
      final profile = credential?.user == null
          ? null
          : await _authService.getUserProfile(credential!.user!.uid);
      await _speak('Sign in successful. Welcome back.');
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
        _step = _VoiceLoginStep.idle;
        _errorMessage = e.toString();
        _statusMessage = 'Sign in failed. Please try again.';
      });
      await _speak('Sign in failed. ${e.toString()}. Please try again.');
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isListening =
        _step == _VoiceLoginStep.listeningEmail ||
        _step == _VoiceLoginStep.listeningPassword;
    final bool canSignIn =
        _step == _VoiceLoginStep.confirming &&
        _email.isNotEmpty &&
        _password.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Semantics(
          label: 'Go back to sign in screen',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Voice Sign In',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Visual indicator
            Semantics(
              label: isListening
                  ? 'Microphone is active, listening'
                  : 'Microphone is inactive',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isListening
                      ? Colors.red.shade50
                      : const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isListening ? Colors.red : const Color(0xFF1A5C5A),
                    width: 3,
                  ),
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  size: 56,
                  color: isListening ? Colors.red : const Color(0xFF1A5C5A),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status
            Semantics(
              label: _statusMessage,
              liveRegion: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Semantics(
                label: 'Error: $_errorMessage',
                liveRegion: true,
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
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // How it works steps
            if (_step == _VoiceLoginStep.idle) ...[
              const Text(
                'How it works:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _stepInfo('1', 'Tap the microphone button'),
              _stepInfo('2', 'Say your email address aloud'),
              _stepInfo('3', 'Say your password aloud'),
              _stepInfo('4', 'Tap Sign In to confirm'),
              const SizedBox(height: 16),
            ],

            // Main action button
            if (_step == _VoiceLoginStep.idle ||
                _step == _VoiceLoginStep.confirming) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Semantics(
                  label: _step == _VoiceLoginStep.idle
                      ? 'Start voice sign in button'
                      : 'Sign in button',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: _step == _VoiceLoginStep.idle
                        ? _startVoiceLogin
                        : canSignIn
                        ? _signIn
                        : null,
                    icon: Icon(
                      _step == _VoiceLoginStep.idle ? Icons.mic : Icons.login,
                    ),
                    label: Text(
                      _step == _VoiceLoginStep.idle
                          ? 'Start Voice Sign In'
                          : 'Sign In',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ),
              if (_step == _VoiceLoginStep.confirming) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Semantics(
                    label: 'Retry voice sign in button',
                    button: true,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _step = _VoiceLoginStep.idle;
                          _email = '';
                          _password = '';
                          _statusMessage =
                              'Tap the microphone to start voice sign in';
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A5C5A),
                        side: const BorderSide(
                          color: Color(0xFF1A5C5A),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],

            if (_step == _VoiceLoginStep.signingIn)
              const CircularProgressIndicator(color: Color(0xFF1A5C5A)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _stepInfo(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF1A5C5A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
