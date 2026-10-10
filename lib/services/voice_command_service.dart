import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Represents a voice command with pattern matching and action
class VoiceCommand {
  final String name;
  final RegExp pattern;
  final Future<void> Function(BuildContext context, String? param) action;
  final String description;

  VoiceCommand({
    required this.name,
    required String pattern,
    required this.action,
    this.description = '',
  }) : pattern = RegExp(pattern, caseSensitive: false);

  /// Try to match input and extract parameter if any
  String? match(String input) {
    final match = pattern.firstMatch(input.trim());
    if (match != null) {
      return match.groupCount > 0 ? match.group(1) : '';
    }
    return null;
  }
}

/// Global voice command service for the entire app
class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastAnnouncement = '';
  
  // Screen-specific commands registry
  final Map<String, List<VoiceCommand>> _screenCommands = {};
  String _currentScreen = 'home';
  
  // Callback for navigation actions
  Function(String action, String? param)? onNavigationCommand;
  
  // Getters
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String get currentScreen => _currentScreen;

  /// Initialize speech recognition and TTS
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      return _isInitialized;
    } catch (e) {
      debugPrint('VoiceCommandService init error: $e');
      return false;
    }
  }

  /// Global commands available on all screens
  List<VoiceCommand> get _globalCommands => [
    VoiceCommand(
      name: 'go_home',
      pattern: r'^(go\s+)?(to\s+)?home$',
      description: 'Navigate to home screen',
      action: (ctx, _) async => onNavigationCommand?.call('go_home', null),
    ),
    VoiceCommand(
      name: 'go_cart',
      pattern: r'^(go\s+)?(to\s+)?(cart|shopping\s*cart)$',
      description: 'Navigate to cart',
      action: (ctx, _) async => onNavigationCommand?.call('go_cart', null),
    ),
    VoiceCommand(
      name: 'go_categories',
      pattern: r'^(go\s+)?(to\s+)?categories$',
      description: 'Navigate to categories',
      action: (ctx, _) async => onNavigationCommand?.call('go_categories', null),
    ),
    VoiceCommand(
      name: 'go_profile',
      pattern: r'^(go\s+)?(to\s+)?profile$',
      description: 'Navigate to profile',
      action: (ctx, _) async => onNavigationCommand?.call('go_profile', null),
    ),
    VoiceCommand(
      name: 'go_back',
      pattern: r'^(go\s+)?back$',
      description: 'Go back to previous screen',
      action: (ctx, _) async => onNavigationCommand?.call('go_back', null),
    ),
    VoiceCommand(
      name: 'search',
      pattern: r'^(search|find|look)\s+(for\s+)?(.+)$',
      description: 'Search for products',
      action: (ctx, query) async => onNavigationCommand?.call('search', query),
    ),
    VoiceCommand(
      name: 'help',
      pattern: r'^(help|commands|what can i say)$',
      description: 'List available commands',
      action: (ctx, _) async => await announceHelp(),
    ),
    VoiceCommand(
      name: 'stop',
      pattern: r'^(stop|quiet|silence)$',
      description: 'Stop speaking',
      action: (ctx, _) async => await stop(),
    ),
    VoiceCommand(
      name: 'repeat',
      pattern: r'^(repeat|say\s+again)$',
      description: 'Repeat last announcement',
      action: (ctx, _) async => await announce(_lastAnnouncement),
    ),
  ];

  /// Register screen-specific commands
  void registerScreen(String screenId, List<VoiceCommand> commands) {
    _screenCommands[screenId] = commands;
    _currentScreen = screenId;
  }

  /// Unregister screen commands
  void unregisterScreen(String screenId) {
    _screenCommands.remove(screenId);
  }

  /// Set current screen context
  void setCurrentScreen(String screenId) {
    _currentScreen = screenId;
  }

  /// Process voice input and execute matching command
  Future<bool> processCommand(BuildContext context, String input) async {
    final cleanInput = input.trim().toLowerCase();
    if (cleanInput.isEmpty) return false;

    // Check screen-specific commands first
    final screenCmds = _screenCommands[_currentScreen] ?? [];
    for (final cmd in screenCmds) {
      final param = cmd.match(cleanInput);
      if (param != null) {
        await cmd.action(context, param.isEmpty ? null : param);
        return true;
      }
    }

    // Then check global commands
    for (final cmd in _globalCommands) {
      // Special handling for search command to extract query
      if (cmd.name == 'search') {
        final searchMatch = RegExp(r'^(?:search|find|look)\s+(?:for\s+)?(.+)$', caseSensitive: false).firstMatch(cleanInput);
        if (searchMatch != null) {
          final query = searchMatch.group(1);
          await cmd.action(context, query);
          return true;
        }
      } else {
        final param = cmd.match(cleanInput);
        if (param != null) {
          await cmd.action(context, param.isEmpty ? null : param);
          return true;
        }
      }
    }

    // No command matched
    await announce("I didn't understand. Say 'help' for available commands.");
    return false;
  }

  /// Start listening for voice input
  Future<void> startListening({
    required BuildContext context,
    required Function(String text) onResult,
    Function()? onDone,
    Function(String error)? onError,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        onError?.call('Voice recognition not available');
        return;
      }
    }

    if (_isListening) {
      await stopListening();
      return;
    }

    _isListening = true;

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            final text = result.recognizedWords;
            onResult(text);
            _isListening = false;
            onDone?.call();
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
    } catch (e) {
      _isListening = false;
      onError?.call(e.toString());
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  /// Announce text via TTS
  Future<void> announce(String text) async {
    if (text.isEmpty) return;
    _lastAnnouncement = text;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stop TTS
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Announce available commands
  Future<void> announceHelp() async {
    final screenCmds = _screenCommands[_currentScreen] ?? [];
    final screenCmdNames = screenCmds.map((c) => c.name.replaceAll('_', ' ')).join(', ');
    
    String help = 'Available commands: ';
    help += 'go home, go cart, go back, search for something, ';
    if (screenCmdNames.isNotEmpty) {
      help += 'and on this screen: $screenCmdNames. ';
    }
    help += "Say 'help' anytime to hear this again.";
    
    await announce(help);
  }

  /// Dispose resources
  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}
