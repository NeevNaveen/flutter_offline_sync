import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('figma transform maps brandPrimary to semantic.primary', () async {
    final packageRoot = Directory.current.path;
    final result = await Process.run(
      'dart',
      ['run', 'tool/figma_to_foundation.dart'],
      workingDirectory: packageRoot,
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    final tokensPath = '$packageRoot/lib/tokens/foundation.tokens.json';
    final tokens = jsonDecode(File(tokensPath).readAsStringSync()) as Map<String, dynamic>;
    final light = tokens['light'] as Map<String, dynamic>;
    final semantic = (light['color'] as Map)['semantic'] as Map<String, dynamic>;
    final primary = semantic['primary'] as Map<String, dynamic>;

    expect(primary[r'$value'], '#2563EB');

    final spacing = ((light['sizes'] as Map)['spacing'] as Map)['md'] as Map;
    expect(spacing[r'$value'], 12);
  });
}
