import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:test/test.dart';

void main() {
  group('rowScopeOf', () {
    test('root write -> null', () {
      expect(rowScopeOf(FieldKey.root), isNull);
    });

    test('flat field -> the field itself', () {
      final key = FieldKey.name('title');
      expect(rowScopeOf(key), key);
    });

    test('nested struct field (no row) -> top-level field', () {
      final key = FieldKey.name('address') + FieldKey.name('zip');
      expect(rowScopeOf(key), FieldKey.name('address'));
    });

    test('field inside a list row -> that row', () {
      final row = FieldKey.name('stops') + FieldKey.id('s1');
      expect(rowScopeOf(row + FieldKey.name('city')), row);
    });

    test('deeply nested rows -> the innermost row', () {
      final inner =
          FieldKey.name('days') +
          FieldKey.id('d1') +
          FieldKey.name('groups') +
          FieldKey.id('g2');
      expect(rowScopeOf(inner + FieldKey.name('name')), inner);
    });

    test('the row key itself -> itself', () {
      final row = FieldKey.name('stops') + FieldKey.id('s1');
      expect(rowScopeOf(row), row);
    });
  });
}
