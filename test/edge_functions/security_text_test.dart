import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('edge functions do not log tokens or exact coordinates with console.log', () {
    final files = Directory('supabase/functions').listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.ts'));
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('console.log')));
    }
  });
}
