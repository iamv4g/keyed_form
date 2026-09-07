import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

void main() {
  group('KSInt & KSDouble & KSNum validators', () {
    test('KSInt min, max, positive default messages', () {
      final v = ks.int().min(10).max(20).positive();

      expect(v.validate(5), 'Must be at least 10');
      expect(v.validate(25), 'Must be at most 20');
      expect(v.validate(15), isNull);
      expect(v.validate(null), 'Required');
    });

    test('KSDouble optional and range default messages', () {
      final v = ks.double().min(0.5).optional();

      expect(v.validate(null), isNull);
      expect(v.validate(0.1), 'Must be at least 0.5');
      expect(v.validate(1.5), isNull);
    });

    test('KSNum general numeric checks', () {
      final v = ks.number().positive();

      expect(v.validate(-5), 'Must be positive');
      expect(v.validate(0), 'Must be positive');
      expect(v.validate(10.5), isNull);
    });
  });
}
