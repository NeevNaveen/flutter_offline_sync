import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:mobile_app/app/app_theme.dart';
import 'package:mobile_app/features/welcome/welcome_page.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key, required this.themeNotifier});

  final FoundationThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    final isLight = themeNotifier.mode == FoundationThemeMode.light;

    return MaterialApp(
      title: 'Offline Sync',
      theme: buildAppTheme(
        foundation: FoundationTheme.light(),
        brightness: Brightness.light,
      ),
      darkTheme: buildAppTheme(
        foundation: FoundationTheme.dark(),
        brightness: Brightness.dark,
      ),
      themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
      home: const WelcomePage(),
    );
  }
}
