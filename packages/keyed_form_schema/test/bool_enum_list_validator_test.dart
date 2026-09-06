import 'package:keyed_form_schema/keyed_form_schema.dart';
import 'package:test/test.dart';

enum TestStatus { draft, published, archived }

void main() {
  group('Bool, Enum, List, Map validators', () {
    test('KSBool trueOnly and required', () {
      final v = ks.boolean().trueOnly(error: .text('Must be accepted'));
      expect(v.validate(false), 'Must be accepted');
      expect(v.validate(true), isNull);

      final req = ks.boolean(error: .text('Required'));
      expect(req.validate(null), 'Required');
      expect(req.validate(false), isNull);
      expect(req.validate(true), isNull);
    });

    test('KSEnum valid values and default messages', () {
      final v = ks.enums<TestStatus>(TestStatus.values);
      expect(v.validate(null), 'Required');
      expect(v.validate(TestStatus.draft), isNull);
      expect(v.validate(TestStatus.published), isNull);
    });

    test('KSList min and nonEmpty default messages', () {
      final v = ks.list(ks.string()).nonEmpty().min(2);

      expect(v.validate([]), 'Must have at least 1 items');
      expect(v.validate(['a']), 'Must have at least 2 items');
      expect(v.validate(['a', 'b']), isNull);
    });

    test('KSMap key/value deep validation and optional', () {
      final optionalMap = ks.map(ks.string(), ks.int()).optional();
      expect(optionalMap.validate(null), isNull);
      expect(optionalMap.validate({'a': 1}), isNull);

      // Deep validation with key & value schemas (auto-inferred types)
      final deep = ks.map(
        ks.string().min(2, error: .text('Key too short')),
        ks.int().positive(error: .text('Value must be positive')),
      );

      expect(deep.validate({'ab': 10}), isNull);
      expect(deep.validate({'a': 10}), 'Key too short');
      expect(deep.validate({'ab': -5}), 'Value must be positive');
    });
  });
}
