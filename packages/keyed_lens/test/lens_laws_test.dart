import 'package:keyed_lens/keyed_lens.dart';
import 'package:test/test.dart';

// Minimal 3-level immutable fixture (days[].groups[].name) — the package
// tests never import the app; copyWith is hand-written so there are no deps.

class Doc {
  const Doc({this.title = '', this.note, this.days = const []});

  final String title;
  final String? note;
  final List<Day> days;

  Doc copyWith({String? title, String? Function()? note, List<Day>? days}) =>
      Doc(
        title: title ?? this.title,
        note: note != null ? note() : this.note,
        days: days ?? this.days,
      );

  @override
  bool operator ==(Object other) =>
      other is Doc &&
      other.title == title &&
      other.note == note &&
      _listEq(other.days, days);

  @override
  int get hashCode => Object.hash(title, note, Object.hashAll(days));
}

class Day {
  const Day({required this.id, this.groups = const []});

  final String id;
  final List<Group> groups;

  Day copyWith({List<Group>? groups}) =>
      Day(id: id, groups: groups ?? this.groups);

  @override
  bool operator ==(Object other) =>
      other is Day && other.id == id && _listEq(other.groups, groups);

  @override
  int get hashCode => Object.hash(id, Object.hashAll(groups));
}

class Group {
  const Group({required this.id, required this.name});

  final String id;
  final String name;

  Group copyWith({String? name}) => Group(id: id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      other is Group && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Segment lenses.
final docTitle = Lens<Doc, String>.of(
  key: FieldKey.name('title'),
  get: (d) => d.title,
  set: (d, v) => d.copyWith(title: v),
);
final docNote = Lens<Doc, String?>.of(
  key: FieldKey.name('note'),
  get: (d) => d.note,
  set: (d, v) => d.copyWith(note: () => v),
);
final docDays = Lens<Doc, List<Day>>.of(
  key: FieldKey.name('days'),
  get: (d) => d.days,
  set: (d, v) => d.copyWith(days: v),
);
final dayGroups = Lens<Day, List<Group>>.of(
  key: FieldKey.name('groups'),
  get: (d) => d.groups,
  set: (d, v) => d.copyWith(groups: v),
);
final groupName = Lens<Group, String>.of(
  key: FieldKey.name('name'),
  get: (g) => g.name,
  set: (g, v) => g.copyWith(name: v),
);

AffineLens<Doc, Day> day(String id) => docDays.at(id, (d) => d.id == id);
AffineLens<Doc, String> groupNameAt(String dayId, String groupId) => day(
  dayId,
).then(dayGroups).at(groupId, (g) => g.id == groupId).then(groupName);

const doc = Doc(
  title: 'Kyoto',
  days: [
    Day(
      id: 'd1',
      groups: [
        Group(id: 'g1', name: 'A'),
        Group(id: 'g2', name: 'B'),
      ],
    ),
    Day(
      id: 'd2',
      groups: [Group(id: 'g3', name: 'C')],
    ),
  ],
);

void main() {
  group('total lens laws', () {
    test('get-set: set(r, get(r)) == r', () {
      expect(docTitle.set(doc, docTitle.get(doc)), doc);
    });

    test('set-get: get(set(r, v)) == v', () {
      expect(docTitle.get(docTitle.set(doc, 'Osaka')), 'Osaka');
    });

    test('set-set: last write wins', () {
      expect(docTitle.set(docTitle.set(doc, 'A'), 'B'), docTitle.set(doc, 'B'));
    });
  });

  group('affine lens laws — present target obeys the total laws', () {
    final lens = groupNameAt('d1', 'g2');

    test('get-set', () {
      expect(lens.set(doc, lens.getOrNull(doc) as String), doc);
    });

    test('set-get', () {
      expect(lens.getOrNull(lens.set(doc, 'B2')), 'B2');
    });

    test('set-set: last write wins', () {
      expect(lens.set(lens.set(doc, 'x'), 'y'), lens.set(doc, 'y'));
    });
  });

  group('affine lens laws — missing target', () {
    final stale = groupNameAt('d1', 'gone');

    test('find is None and getOrNull is null', () {
      expect(stale.find(doc), const None<String>());
      expect(stale.getOrNull(doc), isNull);
      expect(stale.existsIn(doc), isFalse);
    });

    test('set on a missing path is a no-op returning the identical root', () {
      expect(identical(stale.set(doc, 'x'), doc), isTrue);
    });

    test(
      'update on a missing path is a no-op returning the identical root',
      () {
        expect(identical(stale.update(doc, (v) => '$v!'), doc), isTrue);
      },
    );

    test('a missing outer segment behaves the same', () {
      final noDay = groupNameAt('nope', 'g1');
      expect(noDay.getOrNull(doc), isNull);
      expect(identical(noDay.set(doc, 'x'), doc), isTrue);
    });
  });

  group('composition', () {
    test('(a.then(b)).key == a.key + b.key', () {
      final composed = day('d1').then(dayGroups);
      expect(composed.key, day('d1').key + dayGroups.key);
      expect(composed.key.toString(), 'days.d1.groups');
    });

    test('a missing intermediate row makes the whole composition a no-op', () {
      final viaGoneDay = groupNameAt('nope', 'g1');
      expect(viaGoneDay.find(doc), const None<String>());
      expect(identical(viaGoneDay.set(doc, 'x'), doc), isTrue);
    });

    test('total ∘ total via thenTotal stays total (find is always Some)', () {
      final len = docTitle.thenTotal(
        Lens<String, int>.of(
          key: FieldKey.name('length'),
          get: (s) => s.length,
          set: (s, v) => s.padRight(v, '.'),
        ),
      );
      expect(len, isA<Lens<Doc, int>>());
      expect(len.get(doc), 5);
      expect(len.find(doc), const Some(5));
      expect(len.key.toString(), 'title.length');
    });
  });

  group('ListItemLens / .at — lookup is by stable id, not index', () {
    test('reordering siblings keeps resolving the same row', () {
      final reordered = docDays.set(doc, [doc.days[1], doc.days[0]]);
      // d1 moved from index 0 to index 1; the id-keyed lens still finds it.
      expect(groupNameAt('d1', 'g2').getOrNull(reordered), 'B');
      expect(groupNameAt('d2', 'g3').getOrNull(reordered), 'C');
    });

    test('removing the row turns writes into no-ops', () {
      final withoutD1 = docDays.set(doc, [doc.days[1]]);
      final lens = groupNameAt('d1', 'g2');
      expect(lens.getOrNull(withoutD1), isNull);
      expect(identical(lens.set(withoutD1, 'x'), withoutD1), isTrue);
    });

    test('set replaces only the matched element, preserving order', () {
      final lens = ListItemLens<Group>(id: 'g2', matches: (g) => g.id == 'g2');
      final groups = doc.days[0].groups;
      final next = lens.set(groups, const Group(id: 'g2', name: 'Z'));
      expect(next.map((g) => g.name), ['A', 'Z']);
      expect(identical(next[0], groups[0]), isTrue);
    });

    test('duplicate-id list resolves the first match', () {
      final dup = [
        const Group(id: 'g1', name: 'first'),
        const Group(id: 'g1', name: 'second'),
      ];
      final lens = ListItemLens<Group>(id: 'g1', matches: (g) => g.id == 'g1');
      expect(lens.find(dup), const Some(Group(id: 'g1', name: 'first')));
      final next = lens.set(dup, const Group(id: 'g1', name: 'edited'));
      expect(next.map((g) => g.name), ['edited', 'second']);
    });
  });

  group('whenPresent', () {
    final present = docNote.whenPresent();

    test('key is unchanged — same field, refined', () {
      expect(present.key, docNote.key);
    });

    test('null target is missing and set is a no-op', () {
      expect(docNote.get(doc), isNull);
      expect(present.find(doc), const None<String>());
      expect(identical(present.set(doc, 'x'), doc), isTrue);
    });

    test('present target behaves like a normal affine descent', () {
      final seeded = docNote.set(doc, 'seeded');
      expect(present.getOrNull(seeded), 'seeded');
      final updated = present.update(seeded, (n) => '$n!');
      expect(docNote.get(updated), 'seeded!');
    });
  });
}
