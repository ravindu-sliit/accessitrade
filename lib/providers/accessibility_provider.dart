import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:accessitrade/services/user_service.dart';

class AccessibilityProvider extends ChangeNotifier {
  // Preferences
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  bool _voiceEnabled = false;
  bool _textToSpeech = false;
  bool _largerTargets = true;

  // TTS engine
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Getters
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get reduceMotion => _reduceMotion;
  bool get voiceEnabled => _voiceEnabled;
  bool get textToSpeech => _textToSpeech;
  bool get largerTargets => _largerTargets;
  bool get isSpeaking => _isSpeaking;

  AccessibilityProvider() {
    _initTts();
    _loadPreferences();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  Future<void> _loadPreferences() async {
    try {
      final user = await UserService().getCurrentUser();
      if (user != null && user.accessibilityPreferences.isNotEmpty) {
        _highContrast = user.accessibilityPreferences['highContrast'] ?? false;
        _largeText = user.accessibilityPreferences['largeText'] ?? false;
        _voiceEnabled = user.accessibilityPreferences['voiceEnabled'] ?? false;
      }
      notifyListeners();
    } catch (_) {}
  }

  // Update a preference and save to Firestore
  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setLargeText(bool value) async {
    _largeText = value;
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    notifyListeners();
    await _savePreferences();
  }

  Future<void> setTextToSpeech(bool value) async {
    _textToSpeech = value;
    notifyListeners();
  }

  Future<void> setLargerTargets(bool value) async {
    _largerTargets = value;
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    try {
      await UserService().updateAccessibilityPreferences({
        'highContrast': _highContrast,
        'largeText': _largeText,
        'voiceEnabled': _voiceEnabled,
      });
    } catch (_) {}
  }

  // Text-to-Speech methods
  Future<void> speak(String text) async {
    if (_isSpeaking) await stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> speakProductDetails({
    required String name,
    required double price,
    required double rating,
    required int reviewCount,
    required String description,
    required String sellerName,
    required bool inStock,
  }) async {
    final text = '''
      $name.
      Price: Rs. ${price.toStringAsFixed(0)}.
      Rating: $rating out of 5, with $reviewCount reviews.
      ${inStock ? 'In stock.' : 'Out of stock.'}
      Sold by $sellerName.
      Description: $description
    ''';
    await speak(text.trim());
  }

  // Theme helpers
  Color get primaryColor =>
      _highContrast ? const Color(0xFF000000) : const Color(0xFF1A5C5A);

  Color get backgroundColor =>
      _highContrast ? const Color(0xFFFFFFFF) : const Color(0xFFF5F5F0);

  Color get cardColor =>
      _highContrast ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  Color get textColor =>
      _highContrast ? const Color(0xFF000000) : const Color(0xFF1A1A1A);

  Color get secondaryTextColor =>
      _highContrast ? const Color(0xFF000000) : const Color(0xFF666666);

  Color get accentColor =>
      _highContrast ? const Color(0xFF0000FF) : const Color(0xFF1A5C5A);

  double get bodyFontSize => _largeText ? 18.0 : 15.0;
  double get titleFontSize => _largeText ? 26.0 : 22.0;
  double get smallFontSize => _largeText ? 15.0 : 12.0;
  double get buttonHeight => _largerTargets ? 56.0 : 48.0;
  double get minTapTarget => _largerTargets ? 52.0 : 44.0;

  // Build ThemeData based on preferences
  ThemeData buildTheme() {
    if (_highContrast) {
      return ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          primaryContainer: Color(0xFFEEEEEE),
          onPrimaryContainer: Colors.black,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize: _largeText ? 14 : 12, color: Colors.black),
          bodyMedium: TextStyle(fontSize: _largeText ? 17 : 15, color: Colors.black),
          bodyLarge: TextStyle(fontSize: _largeText ? 19 : 17, color: Colors.black),
          titleMedium: TextStyle(fontSize: _largeText ? 20 : 16, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(fontSize: _largeText ? 26 : 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.black12,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: Colors.black),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: Size(0, _largerTargets ? 48 : 44),
            textStyle: TextStyle(fontSize: _largeText ? 18 : 16, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      );
    }

    // Normal (light) theme
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A5C5A),
        brightness: Brightness.light,
        surface: const Color(0xFFF5F5F0),
      ).copyWith(
        primary: const Color(0xFF1A5C5A),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE0F2F1),
        onPrimaryContainer: const Color(0xFF1A5C5A),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5F0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A5C5A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(fontSize: _largeText ? 14 : 12),
        bodyMedium: TextStyle(fontSize: _largeText ? 17 : 15),
        bodyLarge: TextStyle(fontSize: _largeText ? 19 : 17),
        titleMedium: TextStyle(fontSize: _largeText ? 20 : 16, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: _largeText ? 26 : 22, fontWeight: FontWeight.bold),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE0F2F1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Color(0xFF1A5C5A), fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF1A5C5A));
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, _largerTargets ? 48 : 44),
          textStyle: TextStyle(fontSize: _largeText ? 18 : 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}