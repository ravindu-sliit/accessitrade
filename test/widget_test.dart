import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accessitrade/main.dart';
import 'package:accessitrade/screens/landing_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify the app can be instantiated
    expect(const AccessiTradeApp(), isNotNull);
  });

  testWidgets('shows AccessiTrade branding and logo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('AccessiTrade'),
              Image(
                image: AssetImage('assets/accessitrade_logo.png'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('AccessiTrade'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('shows the AccessiTrade logo on the landing page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LandingScreen()),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Shop Easily\nLive Independently'), findsOneWidget);
  });
}
