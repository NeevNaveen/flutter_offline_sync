// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  final packageRoot = _findPackageRoot();
  final bindingsPath = _argValue(args, '--bindings') ??
      p.join(packageRoot, 'tool', 'figma.bindings.json');

  final config = jsonDecode(File(bindingsPath).readAsStringSync()) as Map<String, dynamic>;
  final inputDir = p.join(packageRoot, config['inputDir'] as String? ?? 'assets/figma');
  final templatePath = p.join(packageRoot, config['templatePath'] as String);
  final outputPath = p.join(packageRoot, config['outputPath'] as String);
  final bindings = (config['bindings'] as Map<String, dynamic>?) ?? {};

  if (!File(templatePath).existsSync()) {
    stderr.writeln('Template not found: $templatePath');
    exitCode = 1;
    return;
  }

  final output = jsonDecode(File(templatePath).readAsStringSync()) as Map<String, dynamic>;
  final fileCache = <String, Map<String, dynamic>>{};
  var applied = 0;
  final missing = <String>[];

  bindings.forEach((targetPath, source) {
    if (source is! Map<String, dynamic>) {
      missing.add('$targetPath (invalid binding)');
      return;
    }

    final fileName = source['file'] as String?;
    final tokenKey = source['token'] as String?;
    if (fileName == null || tokenKey == null) {
      missing.add('$targetPath (missing file or token)');
      return;
    }

    final figmaFile = p.join(inputDir, fileName);
    final figmaJson = fileCache.putIfAbsent(
      figmaFile,
      () => jsonDecode(File(figmaFile).readAsStringSync()) as Map<String, dynamic>,
    );

    final figmaToken = _resolveFigmaToken(figmaJson, tokenKey);
    if (figmaToken == null) {
      missing.add('$targetPath ← $fileName#$tokenKey');
      return;
    }

    final canonicalToken = _toCanonicalToken(figmaToken, targetPath);
    _setAtPath(output, targetPath.split('.'), canonicalToken);
    applied++;
    print('Mapped $fileName#$tokenKey → $targetPath');
  });

  final encoder = const JsonEncoder.withIndent('  ');
  File(outputPath).writeAsStringSync('${encoder.convert(output)}\n');

  print('');
  print('Applied $applied binding(s) → $outputPath');
  if (missing.isNotEmpty) {
    print('Missing ${missing.length} binding(s):');
    for (final item in missing) {
      print('  - $item');
    }
    exitCode = 1;
  }
}

String _findPackageRoot() {
  var dir = Directory.current;
  while (true) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not find package root from ${Directory.current.path}');
    }
    dir = parent;
  }
}

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

Map<String, dynamic>? _resolveFigmaToken(Map<String, dynamic> json, String tokenKey) {
  if (json.containsKey(tokenKey) && json[tokenKey] is Map<String, dynamic>) {
    final token = json[tokenKey] as Map<String, dynamic>;
    if (token.containsKey(r'$type') && token.containsKey(r'$value')) {
      return token;
    }
  }

  // Support nested paths such as "Group.tokenName".
  final parts = tokenKey.split('.');
  dynamic current = json;
  for (final part in parts) {
    if (current is! Map<String, dynamic> || !current.containsKey(part)) {
      return null;
    }
    current = current[part];
  }

  if (current is Map<String, dynamic> &&
      current.containsKey(r'$type') &&
      current.containsKey(r'$value')) {
    return current;
  }
  return null;
}

Map<String, dynamic> _toCanonicalToken(Map<String, dynamic> figmaToken, String targetPath) {
  final type = figmaToken[r'$type'] as String;
  final value = figmaToken[r'$value'];
  final description = figmaToken[r'$description'];

  if (targetPath.contains('.typography.')) {
    return {
      r'$type': 'typography',
      r'$value': value is Map<String, dynamic> ? value : _typographyFromScalar(value),
      ?r'$description': description,
    };
  }

  return {
    r'$type': type == 'dimension' ? 'number' : type,
    r'$value': value,
    ?r'$description': description,
  };
}

Map<String, dynamic> _typographyFromScalar(dynamic value) {
  return {
    'fontFamily': r'$font.family.primary',
    'fontSize': value,
    'fontWeight': 400,
    'height': 1.5,
    'letterSpacing': 0,
  };
}

void _setAtPath(Map<String, dynamic> root, List<String> path, Map<String, dynamic> token) {
  if (path.isEmpty) return;

  var current = root;
  for (var i = 0; i < path.length - 1; i++) {
    final key = path[i];
    final next = current[key];
    if (next is! Map<String, dynamic>) {
      throw StateError('Cannot set ${path.join('.')}: "$key" is not an object');
    }
    current = next;
  }

  current[path.last] = token;
}
