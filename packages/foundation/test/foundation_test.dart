import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';

void main() {
  test('generated spacing tokens expose scalar values', () {
    final theme = FoundationTheme.light();
    expect(theme.sizes.spacing.sm, 8);
    expect(theme.sizes.spacing.md, 12);
  });

  test('generated color tokens provide light and dark themes', () {
    final light = FoundationTheme.light();
    final dark = FoundationTheme.dark();

    expect(light.colors.semantic.primary, isNot(equals(dark.colors.semantic.primary)));
    expect(light.colors.semantic.background, isNot(equals(dark.colors.semantic.background)));
  });

  test('foundation theme exposes typography and radius tokens', () {
    final theme = FoundationTheme.light();

    expect(theme.colors.semantic.primary, const Color(0xFF2563EB));
    expect(theme.typography.display.large.fontSize, 36);
    expect(theme.sizes.radius.md, 8);
    expect(theme.sizes.motion.fast, 150);
  });

  test('foundation theme notifier builds ThemeData with extension', () {
    final notifier = FoundationThemeNotifier(initialMode: FoundationThemeMode.light);

    expect(notifier.themeData.extensions.length, 1);
    expect(notifier.theme.colors.semantic.surface, const Color(0xFFFFFFFF));
  });
}
