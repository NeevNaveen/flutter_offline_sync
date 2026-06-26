import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:mobile_app/app/mobile_app.dart';

void main() {
  final themeNotifier = FoundationThemeNotifier(
    initialMode: FoundationThemeMode.light,
  );

  runApp(
    FoundationThemeProvider.builder(
      notifier: themeNotifier,
      builder: (context, notifier) => MobileApp(themeNotifier: notifier),
    ),
  );
}
