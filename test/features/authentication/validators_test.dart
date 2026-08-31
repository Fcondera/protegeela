import 'package:flutter_test/flutter_test.dart';
import 'package:protegeela/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validates email format', () {
      expect(Validators.email('maria@example.com'), isNull);
      expect(Validators.email('maria'), isNotNull);
    });

    test('requires strong enough password length', () {
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password('123'), isNotNull);
    });

    test('validates Brazilian-style phone with DDD', () {
      expect(Validators.phone('(92) 99999-9999'), isNull);
      expect(Validators.phone('9999'), isNotNull);
    });
  });
}
