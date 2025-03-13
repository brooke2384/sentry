import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry/main.dart';
import 'package:sentry/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SentryApp());

    // Verify that welcome screen is displayed
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Verify welcome screen content
    expect(find.byType(Image), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);

    // Test navigation buttons presence
    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
  });
}
