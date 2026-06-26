# Figma → Foundation import guide

This document explains how to reuse the foundation package when Figma token **names** differ from the canonical schema.

## Problem

| Figma export | Foundation schema |
|--------------|-------------------|
| `brandPrimary` | `light.color.semantic.primary` |
| `surfaceCanvas` | `light.color.semantic.background` |
| `space-md` (example) | `light.sizes.spacing.md` |

Widgets call `context.theme.colors.semantic.primary` — they never change.  
You normalize names in **`foundation.tokens.json`** using a transform + bindings file.

## Files

| File | Role |
|------|------|
| `assets/figma/**/*.tokens.json` | Raw Figma W3C exports (any names) |
| `tool/figma.bindings.json` | Explicit map: foundation path → Figma file + token key |
| `lib/tokens/foundation.tokens.json` | Canonical output (matches schema) |
| `lib/schema/foundation-spec.schema.json` | Structure contract for codegen |

## Binding format

Each key is a **target** path in `foundation.tokens.json`:

```json
"light.color.semantic.primary": {
  "file": "Color/Light.tokens.json",
  "token": "brandPrimary"
}
```

- `file` — path under `assets/figma/`
- `token` — key inside that JSON file (supports dots for nested groups, e.g. `"Group.tokenName"`)

No fuzzy matching — every mapping is explicit.

## Example: rename main brand colour

Figma ships `primarySurface` as the main brand colour.

1. Add to `Color/Light.tokens.json`:

```json
"primarySurface": {
  "$type": "color",
  "$value": "#2563EB"
}
```

2. Update binding (not the widgets):

```json
"light.color.semantic.primary": {
  "file": "Color/Light.tokens.json",
  "token": "primarySurface"
}
```

3. Run transform + codegen:

```bash
dart run tool/figma_to_foundation.dart
dart run build_runner build
```

`PrimaryButton` still uses `colors.semantic.primary`.

## Adding a new project

1. Copy or depend on `package:foundation`.
2. Replace `assets/figma/` with that project's Figma exports.
3. Create or adjust `tool/figma.bindings.json` for that project's Figma names.
4. Run `figma_to_foundation.dart` → `build_runner build`.
5. Wire `FoundationThemeProvider` in the app (see README).

## Typography and composite tokens

The transform script fully supports **color** and **number** tokens today.  
**Typography** remains in the template until you add bindings with `"$type": "typography"` sources, or edit `foundation.tokens.json` manually after transform.

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Missing binding: … ← file#token` | Token key missing in Figma JSON, or typo in bindings |
| Widgets show wrong colour | Check binding target path matches `semantic.*` |
| `build_runner` fails | Output JSON must match `foundation-spec.schema.json` |
