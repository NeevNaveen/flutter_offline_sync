import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:mobile_app/app/mobile_app.dart';

void main() {
  testWidgets('welcome page renders with foundation theme', (tester) async {
    final themeNotifier = FoundationThemeNotifier(
      initialMode: FoundationThemeMode.light,
    );

    await tester.pumpWidget(
      FoundationThemeProvider.builder(
        notifier: themeNotifier,
        builder: (context, notifier) => MobileApp(themeNotifier: notifier),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
