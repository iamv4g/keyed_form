import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:test/test.dart';

// Keys shaped like real itinerary paths: days[id].(name | groups[id].name).
FieldKey dayName(String d) =>
    FieldKey.name('days') + FieldKey.id(d) + FieldKey.name('name');
FieldKey day(String d) => FieldKey.name('days') + FieldKey.id(d);
FieldKey groupName(String d, String g) =>
    day(d) + FieldKey.name('groups') + FieldKey.id(g) + FieldKey.name('name');

void main() {
  group('lookup with a key decoded from toPath()', () {
    test('a decoded key hits the same entry as the original', () {
      final key = groupName('d1', 'g2');
      final errors = FieldErrors<String>({key: 'required'});

      final decoded = FieldKey.parse(key.toPath());
      expect(decoded, key); // structural equality is the contract
      expect(errors.byKey(decoded), 'required');
    });

    test(
      'a field ref whose key round-trips through toPath() still looks up',
      () {
        final key = dayName('d1');
        // A field ref carrying a key rebuilt from the serialized path.
        final ref = StrictFieldRef<Object?, Object?>.of(
          key: FieldKey.parse(key.toPath()),
          get: (r) => r,
          set: (r, _) => r,
        );
        final errors = FieldErrors<String>({key: 'too long'});
        expect(errors(ref), 'too long');
      },
    );
  });

  group('iteration preserves document (insertion) order', () {
    final ordered = [
      dayName('d1'),
      groupName('d1', 'g1'),
      groupName('d1', 'g2'),
      dayName('d2'),
    ];

    FieldErrors<int> build() =>
        FieldErrors({for (var i = 0; i < ordered.length; i++) ordered[i]: i});

    test('keys iterate in insertion order', () {
      expect(build().keys, ordered);
    });

    test('order is preserved after removing a subtree', () {
      final pruned = build().removeSubtree(day('d1'));
      expect(pruned.keys, [dayName('d2')]);
    });

    test('removing a subtree that hits nothing keeps every key in order', () {
      final pruned = build().removeSubtree(day('dX'));
      expect(pruned.keys, ordered);
      expect(pruned.length, ordered.length);
    });
  });

  group('removeSubtree removes exactly the descendants, no more no less', () {
    test('a removed day drops its own error and all nested group errors', () {
      final errors = FieldErrors<String>({
        dayName('d1'): 'a',
        groupName('d1', 'g1'): 'b',
        groupName('d1', 'g2'): 'c',
        dayName('d2'): 'd',
        groupName('d2', 'g3'): 'e',
      });

      final pruned = errors.removeSubtree(day('d1'));

      expect(pruned.keys.toSet(), {dayName('d2'), groupName('d2', 'g3')});
      expect(pruned.byKey(dayName('d1')), isNull);
      expect(pruned.byKey(groupName('d1', 'g1')), isNull);
      expect(pruned.byKey(groupName('d1', 'g2')), isNull);
      expect(pruned.byKey(dayName('d2')), 'd');
      expect(pruned.byKey(groupName('d2', 'g3')), 'e');
    });

    test('a sibling with an id that is a prefix string is not removed', () {
      // Removing day 'd1' must not touch day 'd12' — ids compare by value,
      // not by string prefix.
      final errors = FieldErrors<String>({
        dayName('d1'): 'a',
        dayName('d12'): 'b',
      });
      final pruned = errors.removeSubtree(day('d1'));
      expect(pruned.keys.toSet(), {dayName('d12')});
    });

    test('removing the root subtree clears everything', () {
      final errors = FieldErrors<String>({
        dayName('d1'): 'a',
        dayName('d2'): 'b',
      });
      expect(errors.removeSubtree(FieldKey.root).isEmpty, isTrue);
    });
  });
}
