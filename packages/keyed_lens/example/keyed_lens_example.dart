// Keyed optics over a hand-rolled immutable model — no codegen, no Flutter.
//
// This is the bottom of the `keyed_form` stack. The same "Kyoto tour" model
// runs through every package's example; here we use the raw optics directly,
// the way you would for undo/redo, server patches or change tracking.
//
//   dart run example/keyed_lens_example.dart
//
// Next: `keyed_form_core` wraps these types in a "field reference" vocabulary.

import 'package:keyed_lens/keyed_lens.dart';

// ── The immutable model ────────────────────────────────────────────────────
// You write `copyWith` however you like (freezed, dart_mappable, by hand);
// keyed_lens only needs a getter and a copy per field.

class Tour {
  const Tour({required this.title, this.stops = const [], this.notes});

  final String title;
  final List<Stop> stops;
  final String? notes;

  Tour copyWith({String? title, List<Stop>? stops, Object? notes = _unset}) =>
      Tour(
        title: title ?? this.title,
        stops: stops ?? this.stops,
        notes: identical(notes, _unset) ? this.notes : notes as String?,
      );

  @override
  String toString() => 'Tour($title, ${stops.length} stops, notes: $notes)';
}

class Stop {
  const Stop({required this.id, required this.city, required this.nights});

  final String id;
  final String city;
  final int nights;

  Stop copyWith({String? city, int? nights}) =>
      Stop(id: id, city: city ?? this.city, nights: nights ?? this.nights);
}

const _unset = Object();

// ── The leaf accessors ────────────────────────────────────────────────────
// Each carries a FieldKey; composition concatenates behaviour *and* identity.

final tourTitle = Lens<Tour, String>.of(
  key: FieldKey.name('title'),
  get: (t) => t.title,
  set: (t, v) => t.copyWith(title: v),
);

final tourStops = Lens<Tour, List<Stop>>.of(
  key: FieldKey.name('stops'),
  get: (t) => t.stops,
  set: (t, v) => t.copyWith(stops: v),
);

final stopCity = Lens<Stop, String>.of(
  key: FieldKey.name('city'),
  get: (s) => s.city,
  set: (s, v) => s.copyWith(city: v),
);

final stopNights = Lens<Stop, int>.of(
  key: FieldKey.name('nights'),
  get: (s) => s.nights,
  set: (s, v) => s.copyWith(nights: v),
);

/// A typed helper so call sites pass the row id once, never an index.
AffineLens<Tour, Stop> stopById(String id) =>
    tourStops.at(id, (s) => s.id == id);

void main() {
  const original = Tour(
    title: 'Kyoto in autumn',
    stops: [
      Stop(id: 's1', city: 'Kyoto', nights: 3),
      Stop(id: 's2', city: 'Nara', nights: 1),
    ],
  );
  var tour = original;

  // 1. Read / write a scalar field, immutably.
  tour = tourTitle.set(tour, 'Kyoto & Nara in autumn');
  print(tourTitle.get(tour)); // Kyoto & Nara in autumn

  // 2. Compose down to a nested leaf. The composed lens knows its own key.
  final naraNights = stopById('s2').then(stopNights);
  print(naraNights.key.toPath()); // stops.['s2'].nights
  tour = naraNights.update(tour, (n) => n + 1);
  print(naraNights.getOrNull(tour)); // 2

  // 3. Affine safety: a lens to a row that no longer exists just no-ops,
  //    so a stale reference held by an in-flight UI event is harmless.
  final ghost = stopById('nope').then(stopCity);
  print(ghost.getOrNull(tour)); // null
  print(identical(ghost.set(tour, 'Osaka'), tour)); // true — unchanged

  // 4. FieldKey identity: stable, structurally comparable, and reversible.
  final key = naraNights.key;
  print(FieldKey.parse(key.toPath()) == key); // true
  print(key.prefix(2).toPath()); // stops.['s2'] — the row this field lives in

  // 5. Per-field dirty check between the seeded original and the draft.
  print(tourTitle.differs(original, tour)); // true
  print(stopById('s1').then(stopCity).differs(original, tour)); // false

  // 6. A FieldKey round-trips as a path string, so it maps straight back
  //    to a server patch entry.
  print({'path': key.toPath(), 'value': naraNights.getOrNull(tour)});
}
