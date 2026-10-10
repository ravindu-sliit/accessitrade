import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:accessitrade/providers/accessibility_provider.dart';
import 'package:accessitrade/providers/voice_navigation_provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => VoiceNavigationProvider()),
      ],
      child: const AccessiTradeApp(),
    ),
  );
}

class AccessiTradeApp extends StatelessWidget {
  const AccessiTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityProvider>();
    return MaterialApp(
      title: 'AccessiTrade',
      debugShowCheckedModeBanner: false,
      theme: accessibility.buildTheme(),
      home: const SplashScreen(),
    );
  }
}
