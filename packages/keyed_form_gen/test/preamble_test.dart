import 'package:keyed_form_gen/src/generators/preamble.dart';
import 'package:test/test.dart';

void main() {
  group('generatedPreamble', () {
    test(
      'emits the ignore comment and every helper the generator relies on',
      () {
        final preamble = generatedPreamble();

        expect(preamble, contains('// ignore_for_file:'));
        expect(
          preamble,
          contains('bool _listEquals<T>(List<T>? a, List<T>? b)'),
        );
        expect(
          preamble,
          contains('bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b)'),
        );
        expect(preamble, contains('int _mapHash(Map<Object?, Object?>? map)'));
        expect(preamble, contains('const _unset = Object();'));
      },
    );

    test('_listEquals-equivalent semantics: order-sensitive equality', () {
      // Documents the contract the emitted `_listEquals` source must satisfy
      // (a List's identity includes order) — regression guard for the exact
      // string emitted above without re-parsing/evaluating generated Dart.
      final preamble = generatedPreamble();
      final start = preamble.indexOf('bool _listEquals');
      final end = preamble.indexOf('bool _mapEquals');
      final listEqualsSource = preamble.substring(start, end);

      expect(listEqualsSource, contains('a[i] != b[i]'));
      expect(listEqualsSource, isNot(contains('a.length != b.length ? false')));
    });

    test('is deterministic — repeated calls emit byte-identical output', () {
      // The doc comment on generatedPreamble() explains why this matters:
      // both the real PartBuilder and tool/regen_schema.dart call this
      // instead of duplicating the string, specifically so a generator fix
      // can't land in only one of the two places.
      expect(generatedPreamble(), equals(generatedPreamble()));
    });
  });
}
