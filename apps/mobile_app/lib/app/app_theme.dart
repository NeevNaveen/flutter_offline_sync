import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme({
  required FoundationTheme foundation,
  required Brightness brightness,
}) {
  final colors = foundation.colors.semantic;

  final textTheme = TextTheme(
    displayLarge: foundation.typography.display.large,
    headlineLarge: foundation.typography.headline.large,
    titleLarge: foundation.typography.title.large,
    bodyLarge: foundation.typography.body.large,
    bodyMedium: foundation.typography.body.medium,
    labelMedium: foundation.typography.label.medium,
  ).apply(
    bodyColor: colors.textPrimary,
    displayColor: colors.textPrimary,
  );

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    extensions: [foundation],
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
      secondary: colors.secondary,
      onSecondary: brightness == Brightness.dark ? Colors.black : Colors.white,
      error: colors.error,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      elevation: foundation.sizes.elevation.sm,
    ),
  );
}
