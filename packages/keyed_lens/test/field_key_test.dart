import 'package:keyed_lens/keyed_lens.dart';
import 'package:test/test.dart';

void main() {
  test('value equality across separately built instances', () {
    final a = FieldKey.name('days') + FieldKey.id('d1') + FieldKey.name('name');
    final b = FieldKey(const [
      NameSegment('days'),
      IdSegment('d1'),
      NameSegment('name'),
    ]);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('a name segment and an id segment with the same text differ', () {
    expect(FieldKey.name('d1'), isNot(FieldKey.id('d1')));
  });

  test('inequality on differing segments', () {
    expect(
      FieldKey.name('days') + FieldKey.id('d1'),
      isNot(FieldKey.name('days') + FieldKey.id('d2')),
    );
    expect(
      FieldKey.name('days'),
      isNot(FieldKey.name('days') + FieldKey.id('d1')),
    );
  });

  test('toString joins segments with dots', () {
    final key = FieldKey.name(
      'days',
    ).child(const IdSegment('d1')).child(const NameSegment('name'));
    expect(key.toString(), 'days.d1.name');
  });

  test('root is empty and contained in everything', () {
    expect(FieldKey.root.isRoot, isTrue);
    expect(FieldKey.root.contains(FieldKey.name('days')), isTrue);
  });

  test('contains matches self and descendants only', () {
    final day = FieldKey.name('days') + FieldKey.id('d1');
    expect(day.contains(day), isTrue);
    expect(day.contains(day + FieldKey.name('name')), isTrue);
    expect(day.contains(FieldKey.name('days') + FieldKey.id('d2')), isFalse);
    expect(day.contains(FieldKey.name('days')), isFalse);
  });

  test('usable as map key', () {
    final key =
        FieldKey.name('days') + FieldKey.id('d1') + FieldKey.name('name');
    final errors = <FieldKey, String>{key: 'required'};
    final lookup =
        FieldKey.name('days') + FieldKey.id('d1') + FieldKey.name('name');
    expect(errors[lookup], 'required');
  });

  test('segments support exhaustive pattern matching', () {
    final key = FieldKey.name('days') + FieldKey.id('d1');
    final kinds = key.segments
        .map(
          (s) => switch (s) {
            NameSegment(:final name) => 'name:$name',
            IdSegment(:final id) => 'id:$id',
          },
        )
        .toList();
    expect(kinds, ['name:days', 'id:d1']);
  });
}
