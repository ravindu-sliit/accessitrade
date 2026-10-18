import 'package:flutter/material.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/services/voice_command_service.dart';

/// Provider for managing voice navigation state across the app
class VoiceNavigationProvider extends ChangeNotifier {
  final VoiceCommandService _voiceService = VoiceCommandService();
  
  VoiceNavigationProvider() {
    // Set up navigation command handler immediately
    _voiceService.onNavigationCommand = _handleNavigationCommand;
  }
  
  // Current screen context
  String _currentScreen = 'home';
  
  // For list navigation (search results, cart items)
  int _currentItemIndex = 0;
  int _totalItems = 0;
  
  // Voice state
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _feedback = '';
  
  // Navigation callback
  GlobalKey<NavigatorState>? navigatorKey;
  Function(int tabIndex)? onTabChange;
  Function(String query)? onSearch;
  
  // Reference to check if voice is enabled
  bool _voiceEnabledOverride = true;

  void setVoiceEnabled(bool enabled) {
    _voiceEnabledOverride = enabled;
  }
  
  // Getters
  String get currentScreen => _currentScreen;
  int get currentItemIndex => _currentItemIndex;
  int get totalItems => _totalItems;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String get recognizedText => _recognizedText;
  String get feedback => _feedback;
  VoiceCommandService get voiceService => _voiceService;
  
  /// Initialize the voice service
  Future<bool> initialize() async {
    final success = await _voiceService.initialize();
    
    // Set up navigation command handler
    _voiceService.onNavigationCommand = _handleNavigationCommand;
    
    return success;
  }

  /// Handle navigation commands from voice service
  void _handleNavigationCommand(String action, String? param) {
    debugPrint('📢 NAV: Handling navigation command: $action, param: $param');
    debugPrint('📢 NAV: onTabChange is ${onTabChange != null ? "SET" : "NULL"}');
    switch (action) {
      case 'go_home':
        onTabChange?.call(0);
        _provideFeedback('Going to home');
        break;
      case 'go_categories':
        onTabChange?.call(1);
        _provideFeedback('Going to categories');
        break;
      case 'go_community':
        onTabChange?.call(2);
        _provideFeedback('Going to community');
        break;
      case 'go_cart':
        onTabChange?.call(3);
        _provideFeedback('Going to cart');
        break;
      case 'go_profile':
        onTabChange?.call(4);
        _provideFeedback('Going to profile');
        break;
      case 'go_back':
        navigatorKey?.currentState?.pop();
        _provideFeedback('Going back');
        break;
      case 'search':
        if (param != null && param.isNotEmpty) {
          _provideFeedback('Searching for $param');
          onSearch?.call(param);
        }
        break;
    }
    notifyListeners();
  }

  /// Set current screen and optionally item count
  void setScreen(String screen, {int? itemCount}) {
    _currentScreen = screen;
    _voiceService.setCurrentScreen(screen);
    if (itemCount != null) {
      _totalItems = itemCount;
      _currentItemIndex = 0;
    }
    notifyListeners();
  }

  /// Move to next item in list
  void nextItem() {
    if (_currentItemIndex < _totalItems - 1) {
      _currentItemIndex++;
      notifyListeners();
    } else {
      _provideFeedback('At last item');
    }
  }

  /// Move to previous item in list
  void previousItem() {
    if (_currentItemIndex > 0) {
      _currentItemIndex--;
      notifyListeners();
    } else {
      _provideFeedback('At first item');
    }
  }

  /// Jump to specific item
  void goToItem(int index) {
    if (index >= 0 && index < _totalItems) {
      _currentItemIndex = index;
      notifyListeners();
    }
  }

  /// Reset item index
  void resetItemIndex() {
    _currentItemIndex = 0;
    notifyListeners();
  }

  /// Start listening for voice commands
  Future<void> startListening(BuildContext context) async {
    if (_isListening) {
      await stopListening();
      return;
    }

    _isListening = true;
    _recognizedText = '';
    notifyListeners();

    await _voiceService.startListening(
      context: context,
      onResult: (text) {
        _recognizedText = text;
        _isProcessing = true;
        notifyListeners();
        
        // Process the command
        _voiceService.processCommand(context, text).then((success) {
          _isProcessing = false;
          if (!success) {
            _feedback = "Didn't understand: $text";
          }
          notifyListeners();
        });
      },
      onDone: () {
        _isListening = false;
        notifyListeners();
      },
      onError: (error) {
        _isListening = false;
        _feedback = error;
        notifyListeners();
      },
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    await _voiceService.stopListening();
    notifyListeners();
  }

  /// Announce text via TTS
  Future<void> announce(String text) async {
    if (!_voiceEnabledOverride) return;
    await _voiceService.announce(text);
  }

  /// Stop TTS
  Future<void> stopAnnouncement() async {
    await _voiceService.stop();
  }

  /// Set feedback message
  void _provideFeedback(String message) {
    if (!_voiceEnabledOverride) return;
    _feedback = message;
    notifyListeners();
  }

  /// Clear feedback
  void clearFeedback() {
    _feedback = '';
    notifyListeners();
  }

  /// Register screen-specific commands
  void registerScreenCommands(String screenId, List<VoiceCommand> commands) {
    _voiceService.registerScreen(screenId, commands);
  }

  /// Unregister screen commands
  void unregisterScreenCommands(String screenId) {
    _voiceService.unregisterScreen(screenId);
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
