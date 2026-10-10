# Voice-First Navigation Flow Specification
## C1 – Accessible Product Discovery & Search

**Version:** 2.0 | **Date:** 2026-10-17 | **Author:** IT23829510 (Ravindu Sooriyaarachchi)

---

## 1. Overview

Enable visually impaired users to navigate AccessiTrade from login to checkout using only voice commands.

**Primary Persona:** Nimal Perera (55yo, legally blind, uses VoiceOver)

---

## 2. Current State

### Working ✅
| Feature | File |
|---------|------|
| Voice Login | `lib/screens/auth/voice_login_screen.dart` |
| Voice Search | `lib/screens/discovery/search_screen.dart` (autoStartVoice param) |
| Auto-read Results | `lib/screens/discovery/search_results_screen.dart` (fromVoice param) |
| TTS Listen Button | `lib/screens/discovery/product_details_screen.dart` |
| TTS Engine | `lib/providers/accessibility_provider.dart` (speakProductDetails) |
| Speech-to-Text | `lib/services/voice_service.dart` |

### Missing ❌
- Global voice command system
- Voice navigation between screens
- Auto-announce on screen change
- Voice product selection (next/prev/select)
- Voice add-to-cart from list
- Voice checkout flow

---

## 3. New Files (5)

### 3.1 lib/services/voice_command_service.dart
```dart
class VoiceCommandService {
  final SpeechToText _speech;
  final FlutterTts _tts;
  final Map<String, List<VoiceCommand>> _screenCommands = {};
  
  // Global commands
  final _globalCommands = [
    VoiceCommand(pattern: r'go.*(home|back)', action: (ctx) => ...),
    VoiceCommand(pattern: r'go.*cart', action: (ctx) => ...),
    VoiceCommand(pattern: r'search(.+)', action: (ctx, q) => ...),
    VoiceCommand(pattern: r'help', action: (ctx) => ...),
  ];
  
  Future<bool> processCommand(BuildContext ctx, String input);
  void registerScreen(String id, List<VoiceCommand> cmds);
  Future<void> announce(String text);
}
```

### 3.2 lib/providers/voice_navigation_provider.dart
```dart
class VoiceNavigationProvider extends ChangeNotifier {
  String _currentScreen = 'home';
  int _currentItemIndex = 0;
  int _totalItems = 0;
  bool _isListening = false;
  
  void setScreen(String screen, {int? itemCount});
  void nextItem();
  void previousItem();
  void selectCurrentItem();
}
```

### 3.3 lib/widgets/voice_fab.dart
```dart
class VoiceFAB extends StatelessWidget {
  // Floating mic button, red when listening
  // Positioned bottom-right on all screens
}
```

### 3.4 lib/widgets/voice_overlay.dart
```dart
class VoiceOverlay extends StatelessWidget {
  // Full-screen listening indicator
  // Shows waveform + recognized text
}
```

### 3.5 lib/mixins/voice_screen_mixin.dart
```dart
mixin VoiceScreenMixin<T extends StatefulWidget> on State<T> {
  void registerVoiceCommands(List<VoiceCommand> commands);
  void announceScreen(String message);
}
```

---

## 4. File Modifications

### 4.1 main.dart
**Add:** VoiceNavigationProvider to MultiProvider
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
    ChangeNotifierProvider(create: (_) => VoiceNavigationProvider()),
  ],
  child: AccessiTradeApp(),
)
```

### 4.2 landing_screen.dart
**Add:** Voice sign-in button + auto-announce
```dart
// In initState or build:
accessibility.announce("Welcome to AccessiTrade. Say sign in or create account.");

// Add button after Sign In:
OutlinedButton.icon(
  icon: Icon(Icons.mic),
  label: Text('Sign In with Voice'),
  onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => VoiceLoginScreen())),
)
```

### 4.3 home_screen.dart
**Add:** VoiceFAB + tab navigation commands
```dart
Scaffold(
  body: ...,
  floatingActionButton: VoiceFAB(
    onCommand: (cmd) {
      if (cmd.contains('cart')) setState(() => _currentIndex = 2);
      if (cmd.contains('home')) setState(() => _currentIndex = 0);
      if (cmd.contains('categories')) setState(() => _currentIndex = 1);
      if (cmd.contains('profile')) setState(() => _currentIndex = 3);
    },
  ),
)
```

### 4.4 home_tab.dart
**Add:** Auto-announce on load
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AccessibilityProvider>().speak(
      "Welcome to AccessiTrade. Say search, or tap the mic button."
    );
  });
}
```

### 4.5 search_results_screen.dart
**Add:** Item navigation (next/prev/select)
```dart
int _currentIndex = 0;

void _nextProduct() {
  if (_currentIndex < results.length - 1) {
    setState(() => _currentIndex++);
    _announceCurrentProduct();
  }
}

void _previousProduct() {
  if (_currentIndex > 0) {
    setState(() => _currentIndex--);
    _announceCurrentProduct();
  }
}

void _selectCurrent() {
  Navigator.push(ctx, MaterialPageRoute(
    builder: (_) => ProductDetailsScreen(product: results[_currentIndex])
  ));
}

void _addCurrentToCart() async {
  await _cartService.addToCart(results[_currentIndex]);
  _tts.speak("Added ${results[_currentIndex].name} to cart.");
}
```

### 4.6 product_details_screen.dart
**Add:** Auto-read on open + voice add-to-cart
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AccessibilityProvider>().speakProductDetails(
      name: widget.product.name,
      price: widget.product.price,
      rating: widget.product.rating,
      ...
    );
  });
}

// Voice command handler:
if (command.contains('add to cart')) {
  await _cartService.addToCart(widget.product);
  _tts.speak("Added to cart. Say go to cart or continue shopping.");
}
```

### 4.7 cart_screen.dart
**Add:** Voice read cart + checkout commands
```dart
void _readCart(List<CartItem> items, double total) {
  final count = items.length;
  final itemList = items.map((i) => "${i.productName}, quantity ${i.quantity}").join(". ");
  _tts.speak("Cart has $count items. $itemList. Total Rs ${total.toStringAsFixed(0)}. Say checkout or continue shopping.");
}

// Checkout voice commands:
// "confirm" -> nextStep()
// "standard" / "express" -> setDeliveryMethod()
// "cash" / "card" -> setPaymentMethod()
// "place order" -> placeOrder()
```

---

## 5. Voice Commands

| Command | Pattern | Screen | Action |
|---------|---------|--------|--------|
| go home | `go.*home` | Global | Tab 0 |
| go cart | `go.*cart` | Global | Tab 2 |
| go back | `back` | Global | Navigator.pop |
| search X | `search\s+(.+)` | Global | Search query |
| help | `help` | Global | List commands |
| next | `next` | Results | Next item |
| previous | `prev` | Results | Previous item |
| select | `select\|open` | Results | Open product |
| add to cart | `add.*cart` | Results/Product | Add current |
| read cart | `read.*cart` | Cart | Announce items |
| checkout | `checkout` | Cart | Start checkout |
| confirm | `confirm\|yes` | Checkout | Next step |
| place order | `place.*order` | Checkout | Complete |

---

## 6. Auto-Announcements

| Screen | Message |
|--------|---------|
| Landing | "Welcome to AccessiTrade. Say sign in or create account." |
| Home | "Home. {N} products. Say search or help." |
| Results | "Found {N} for {query}. First: {name}, Rs {price}. Say next or select." |
| Product | "{name}. Rs {price}. {rating} stars. Say add to cart." |
| Cart | "Cart: {N} items. Rs {total}. Say checkout." |
| Checkout | "Step {N}: {step}. Say confirm." |
| Confirmation | "Order placed! Number {id}. Delivery {date}." |

---

## 7. Implementation (19 hours)

| Phase | Task | Hours |
|-------|------|-------|
| 1 | VoiceCommandService + VoiceNavigationProvider | 4 |
| 2 | VoiceFAB + main.dart integration | 3 |
| 3 | landing + home_screen + home_tab auto-announce | 3 |
| 4 | search_results_screen next/prev/select | 4 |
| 5 | product_details auto-read + voice add | 2 |
| 6 | cart_screen voice checkout | 3 |

---

## 8. Success Criteria

- [ ] Voice-only login
- [ ] Voice search
- [ ] Voice navigation in results (next/prev/select)
- [ ] Voice add to cart
- [ ] Voice checkout completion
- [ ] All screens auto-announce
- [ ] Help command works everywhere

---

End of Specification
