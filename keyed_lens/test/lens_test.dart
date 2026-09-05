import 'package:keyed_lens/keyed_lens.dart';
import 'package:test/test.dart';

// Hand-rolled nested immutable model standing in for a real aggregate
// (days[].groups[].name). In an application these copyWith bodies come from
// codegen (dart_mappable/freezed); here they are written out so the test
// has no dependencies.

class Tour {
  const Tour({required this.title, this.note, this.days = const []});

  final String title;
  final String? note;
  final List<Day> days;

  Tour copyWith({String? title, String? Function()? note, List<Day>? days}) =>
      Tour(
        title: title ?? this.title,
        note: note != null ? note() : this.note,
        days: days ?? this.days,
      );
}

class Day {
  const Day({required this.id, this.groups = const []});

  final String id;
  final List<Group> groups;

  Day copyWith({List<Group>? groups}) =>
      Day(id: id, groups: groups ?? this.groups);
}

class Group {
  const Group({required this.id, required this.name});

  final String id;
  final String name;

  Group copyWith({String? name}) => Group(id: id, name: name ?? this.name);
}

// Segment lenses — written once per segment, composed everywhere else.

final tourTitle = Lens<Tour, String>.of(
  key: FieldKey.name('title'),
  get: (t) => t.title,
  set: (t, v) => t.copyWith(title: v),
);

final tourNote = Lens<Tour, String?>.of(
  key: FieldKey.name('note'),
  get: (t) => t.note,
  set: (t, v) => t.copyWith(note: () => v),
);

final tourDays = Lens<Tour, List<Day>>.of(
  key: FieldKey.name('days'),
  get: (t) => t.days,
  set: (t, v) => t.copyWith(days: v),
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

AffineLens<Tour, Day> day(String id) => tourDays.at(id, (d) => d.id == id);

AffineLens<Tour, String> groupNameAt(String dayId, String groupId) => day(
  dayId,
).then(dayGroups).at(groupId, (g) => g.id == groupId).then(groupName);

const tour = Tour(
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
  group('total lens', () {
    test('get/set/modify', () {
      expect(tourTitle.get(tour), 'Kyoto');
      expect(tourTitle.set(tour, 'Osaka').title, 'Osaka');
      expect(tourTitle.modify(tour, (t) => '$t!').title, 'Kyoto!');
    });

    test('thenTotal keeps non-null get', () {
      final firstDayViaTotal = tourTitle.thenTotal(
        Lens<String, int>.of(
          key: FieldKey.name('length'),
          get: (s) => s.length,
          set: (s, v) => s.substring(0, v),
        ),
      );
      expect(firstDayViaTotal.get(tour), 5);
      expect(firstDayViaTotal.key.toString(), 'title.length');
    });
  });

  group('composed affine lens', () {
    test('reads a deep leaf', () {
      expect(groupNameAt('d1', 'g2').getOrNull(tour), 'B');
    });

    test('key concatenates through composition', () {
      expect(groupNameAt('d1', 'g2').key.toString(), 'days.d1.groups.g2.name');
    });

    test('set rebuilds the spine and shares unrelated branches', () {
      final next = groupNameAt('d1', 'g2').set(tour, 'B2');
      expect(groupNameAt('d1', 'g2').getOrNull(next), 'B2');
      // Untouched leaf still there, untouched branches are the same objects.
      expect(groupNameAt('d1', 'g1').getOrNull(next), 'A');
      expect(identical(next.days[1], tour.days[1]), isTrue);
      expect(identical(next.days[0].groups[0], tour.days[0].groups[0]), isTrue);
      expect(identical(next, tour), isFalse);
    });

    test('update transforms in place along the same path', () {
      final next = groupNameAt('d2', 'g3').update(tour, (n) => n.toLowerCase());
      expect(groupNameAt('d2', 'g3').getOrNull(next), 'c');
    });
  });

  group('affine miss semantics (stale lens after row removal)', () {
    final stale = groupNameAt('d1', 'gone');

    test('find is None, getOrNull is null, existsIn is false', () {
      expect(stale.find(tour), const None<String>());
      expect(stale.getOrNull(tour), isNull);
      expect(stale.existsIn(tour), isFalse);
    });

    test('set and update are no-ops returning the identical root', () {
      expect(identical(stale.set(tour, 'X'), tour), isTrue);
      expect(identical(stale.update(tour, (v) => v), tour), isTrue);
    });

    test('miss at the outer segment behaves the same', () {
      final noDay = groupNameAt('nope', 'g1');
      expect(noDay.getOrNull(tour), isNull);
      expect(identical(noDay.set(tour, 'X'), tour), isTrue);
    });
  });

  group('nullable leaf: missing vs present-but-null', () {
    test('find distinguishes what getOrNull cannot', () {
      final viaDay = day('d1').then(
        AffineLens<Day, String?>.of(
          key: FieldKey.name('label'),
          find: (_) => const Some<String?>(null),
          set: (d, _) => d,
        ),
      );
      final viaGone = day('gone').then(
        AffineLens<Day, String?>.of(
          key: FieldKey.name('label'),
          find: (_) => const Some<String?>(null),
          set: (d, _) => d,
        ),
      );
      expect(viaDay.find(tour), const Some<String?>(null));
      expect(viaGone.find(tour), const None<String?>());
      expect(tourNote.get(tour), isNull);
    });
  });

  group('ListItemLens', () {
    final second = ListItemLens<Group>(id: 'g2', matches: (g) => g.id == 'g2');

    test('replaces only the matched element, preserving order', () {
      final groups = tour.days[0].groups;
      final next = second.set(groups, const Group(id: 'g2', name: 'Z'));
      expect(next.map((g) => g.name), ['A', 'Z']);
      expect(identical(next[0], groups[0]), isTrue);
    });

    test('no match returns the identical list', () {
      final groups = tour.days[1].groups;
      expect(
        identical(second.set(groups, const Group(id: 'g2', name: 'Z')), groups),
        isTrue,
      );
    });
  });

  group('differs (per-field dirty)', () {
    test('total lens compares values across roots', () {
      expect(tourTitle.differs(tour, tourTitle.set(tour, 'Osaka')), isTrue);
      expect(tourTitle.differs(tour, tour), isFalse);
    });

    test('deep affine leaf: only the edited field differs', () {
      final edited = groupNameAt('d1', 'g2').set(tour, 'B2');
      expect(groupNameAt('d1', 'g2').differs(tour, edited), isTrue);
      expect(groupNameAt('d1', 'g1').differs(tour, edited), isFalse);
    });

    test('missing-vs-present differs; missing in both does not', () {
      final gone = groupNameAt('d1', 'nope');
      final withoutG2 = tourDays.set(tour, [
        const Day(
          id: 'd1',
          groups: [Group(id: 'g1', name: 'A')],
        ),
        tour.days[1],
      ]);
      expect(groupNameAt('d1', 'g2').differs(tour, withoutG2), isTrue);
      expect(gone.differs(tour, withoutG2), isFalse);
    });
  });

  group('whenPresent (nullable field refinement)', () {
    final presentNote = tourNote.whenPresent();

    test('key is unchanged — same field, refined', () {
      expect(presentNote.key, tourNote.key);
    });

    test('null field is missing: find None, set is a no-op', () {
      expect(tourNote.get(tour), isNull);
      expect(presentNote.find(tour), const None<String>());
      expect(identical(presentNote.set(tour, 'x'), tour), isTrue);
    });

    test('non-null field reads and writes as non-null', () {
      final seeded = tourNote.set(tour, 'seeded');
      expect(presentNote.getOrNull(seeded), 'seeded');
      final updated = presentNote.update(seeded, (n) => '$n!');
      expect(tourNote.get(updated), 'seeded!');
    });
  });
}
