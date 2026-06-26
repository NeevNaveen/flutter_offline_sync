# foundation

Reusable design-system package for `flutter_offline_sync`. Tokens are authored in **W3C Design Tokens** format (`$type` / `$value`) and codegen is handled by [`design_builder`](https://pub.dev/packages/design_builder).

## Structure

```
packages/foundation/
├── lib/
│   ├── foundation.dart                 # Public export
│   ├── schema/
│   │   └── foundation-spec.schema.json # Token contract (groups + types)
│   ├── tokens/
│   │   └── foundation.tokens.json      # Source of truth (light + dark)
│   └── src/generated/
│       └── foundation_theme.g.dart     # Generated — do not edit
├── assets/figma/                       # Example Figma Variable exports (reference)
└── build.yaml                          # build_runner / design_builder config
```

## Token format (W3C / Figma-compatible)

Each token uses the standard W3C shape:

```json
"sm": {
  "$type": "number",
  "$value": 8
}
```

```json
"primary": {
  "$type": "color",
  "$value": "#2563EB"
}
```

```json
"large": {
  "$type": "typography",
  "$value": {
    "fontFamily": "$font.family.primary",
    "fontSize": 36,
    "fontWeight": 700,
    "height": 1.2222
  }
}
```

- **Light / dark** modes live under top-level `"light"` and `"dark"` keys.
- **Variables** use `$variables` and `$font.family.primary` references (resolved at build time).
- **Figma Variables** export the same `$type` / `$value` shape. See `assets/figma/` for collection/mode examples (`Spacing/Default.tokens.json`, `Color/Light.tokens.json`).

When designers update Figma, export Variables (W3C) into `assets/figma/`, then run the transform script (below).

## Import from Figma (transform + bindings)

Figma exports often use **different token names** than your schema (`brandPrimary` vs `semantic.primary`).  
Map them once in `tool/figma.bindings.json`, then generate canonical `foundation.tokens.json`.

```
assets/figma/                    tool/figma.bindings.json
  Color/Light.tokens.json    →     light.color.semantic.primary ← brandPrimary
  Color/Dark.tokens.json           dark.color.semantic.primary ← brandPrimary
  Spacing/Default.tokens.json      light.sizes.spacing.md ← md
        │                                    │
        └──────────────┬─────────────────────┘
                       ▼
              dart run tool/figma_to_foundation.dart
                       ▼
           lib/tokens/foundation.tokens.json   (canonical names)
                       ▼
              dart run build_runner build
                       ▼
           lib/src/generated/foundation_theme.g.dart
```

### Steps

```bash
cd packages/foundation

# 1. Export W3C tokens from Figma into assets/figma/{Collection}/{Mode}.tokens.json

# 2. Edit tool/figma.bindings.json — map Figma token → foundation path:
#    "light.color.semantic.primary": { "file": "Color/Light.tokens.json", "token": "brandPrimary" }

# 3. Transform (uses foundation.tokens.json as template for unmapped tokens)
dart run tool/figma_to_foundation.dart

# 4. Regenerate Dart theme
dart run build_runner build
```

Options:

```bash
dart run tool/figma_to_foundation.dart --bindings tool/figma.bindings.json
```

**What stays from the template:** typography, motion, shadow, elevation, and any path not listed in bindings.  
**What you change per project:** Figma exports + bindings only — widgets stay the same.

See [doc/FIGMA_IMPORT.md](doc/FIGMA_IMPORT.md) for a full walkthrough.

## Code generation

```bash
cd packages/foundation
flutter pub get
dart run build_runner build
```

Watch during development:

```bash
dart run build_runner watch
```

## Usage in apps

```dart
import 'package:foundation/foundation.dart';

void main() {
  runApp(
    FoundationThemeProvider(
      notifier: FoundationThemeNotifier(initialMode: FoundationThemeMode.light),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: context.themeNotifier.themeData,
      home: Builder(
        builder: (context) {
          final theme = context.theme;
          return Padding(
            padding: EdgeInsets.all(theme.sizes.spacing.md),
            child: Text(
              'Tasks',
              style: theme.typography.title.large.copyWith(
                color: theme.colors.semantic.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## API map (old → new)

| Before (custom generator) | After (`design_builder`) |
|---------------------------|--------------------------|
| `FoundationTokens.spacing.md` | `context.theme.sizes.spacing.md` |
| `FoundationTokens.lightColors.primary` | `FoundationTheme.light().colors.semantic.primary` |
| `FoundationTokens.typography.titleLarge` | `context.theme.typography.title.large` |
| `FoundationTokens.theme(...)` | `FoundationThemeNotifier(...).themeData` |

## Extending tokens

1. Update `lib/schema/foundation-spec.schema.json` if you add new groups or categories.
2. Add tokens to `lib/tokens/foundation.tokens.json` under `light` / `dark`.
3. Run `dart run build_runner build`.

The schema drives discovery — `design_builder` reads group names from the schema and parses matching JSON automatically.
