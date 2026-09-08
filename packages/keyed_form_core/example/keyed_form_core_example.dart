// The shared "field reference" vocabulary the whole keyed_form family speaks.
//
// `keyed_form_core` sits on `keyed_lens` but never says "lens": a field is a
// `FieldRef` / `StrictFieldRef` / `VariantRef`, and per-field data (errors,
// dirty flags, …) lives in a `FieldErrors` sidecar looked up *by that same
// ref*. This is exactly the shape `keyed_form_gen` emits — written by hand
// here so you can see it.
//
//   dart run example/keyed_form_core_example.dart

import 'package:keyed_form_core/keyed_form_core.dart';

// ── Model ─────────────────────────────────────────────────────────────────

class Tour {
  const Tour({this.title = '', this.stops = const [], this.notes});

  final String title;
  final List<Stop> stops;
  final String? notes;

  Tour copyWith({String? title, List<Stop>? stops, Object? notes = _unset}) =>
      Tour(
        title: title ?? this.title,
        stops: stops ?? this.stops,
        notes: identical(notes, _unset) ? this.notes : notes as String?,
      );
}

class Stop implements KeyedRow {
  const Stop({required this.clientId, this.city = '', this.nights = 1});

  @override
  final String clientId;
  final String city;
  final int nights;

  Stop copyWith({String? city, int? nights}) =>
      Stop(clientId: clientId, city: city ?? this.city, nights: nights ?? this.nights);
}

const _unset = Object();

// ── Field references ──────────────────────────────────────────────────────
// `StrictFieldRef` for scalars that always resolve; a `DelegatingFieldRef`
// wrapper for a list row, whose leaf getters are affine (`FieldRef`) because
// the row may be gone.

abstract final class StopFields {
  static StrictFieldRef<Stop, String> get city => StrictFieldRef<Stop, String>.of(
        key: FieldKey.name('city'),
        get: (s) => s.city,
        set: (s, v) => s.copyWith(city: v),
      );

  static StrictFieldRef<Stop, int> get nights => StrictFieldRef<Stop, int>.of(
        key: FieldKey.name('nights'),
        get: (s) => s.nights,
        set: (s, v) => s.copyWith(nights: v),
      );
}

final class StopFieldRefs extends DelegatingFieldRef<Tour, Stop> {
  StopFieldRefs(super.inner);

  FieldRef<Tour, String> get city => inner.then(StopFields.city);
  FieldRef<Tour, int> get nights => inner.then(StopFields.nights);
}

abstract final class TourFields {
  static StrictFieldRef<Tour, String> get title =>
      StrictFieldRef<Tour, String>.of(
        key: FieldKey.name('title'),
        get: (t) => t.title,
        set: (t, v) => t.copyWith(title: v),
      );

  static StrictFieldRef<Tour, List<Stop>> get stops =>
      StrictFieldRef<Tour, List<Stop>>.of(
        key: FieldKey.name('stops'),
        get: (t) => t.stops,
        set: (t, v) => t.copyWith(stops: v),
      );

  static StrictFieldRef<Tour, String?> get notes =>
      StrictFieldRef<Tour, String?>.of(
        key: FieldKey.name('notes'),
        get: (t) => t.notes,
        set: (t, v) => t.copyWith(notes: v),
      );

  /// Affine field references for one `stops` row, addressed by clientId.
  static StopFieldRefs stop(String clientId) =>
      StopFieldRefs(stops.at(clientId, (s) => s.clientId == clientId));
}

void main() {
  var tour = const Tour(
    title: 'Ky',
    stops: [
      Stop(clientId: 'a', city: 'Kyoto', nights: 3),
      Stop(clientId: 'b', city: '', nights: 1),
    ],
  );

  // 1. Read / write through the vocabulary — same handle either direction.
  tour = TourFields.title.set(tour, 'Kyoto in autumn');
  tour = TourFields.stop('b').city.set(tour, 'Nara');
  print(TourFields.stop('b').city.getOrNull(tour)); // Nara

  // 2. A ref to a row that is gone reads null and writes no-op.
  print(TourFields.stop('gone').nights.getOrNull(tour)); // null

  // 3. FieldErrors — a FieldKey-keyed sidecar, but you look it up by *ref*.
  final errors = FieldErrors<String>({
    TourFields.title.key: 'Too short',
    TourFields.stop('a').city.key: 'Unknown city',
  });
  print(errors(TourFields.stop('a').city)); // Unknown city
  print(errors(TourFields.stop('b').city)); // null

  // 4. whenPresent() refines a nullable field to its non-null value.
  final notes = TourFields.notes.whenPresent();
  print(notes.getOrNull(tour)); // null — the field holds null
  tour = TourFields.notes.set(tour, 'Bring a warm coat');
  print(notes.getOrNull(tour)); // Bring a warm coat

  // 5. removeSubtree() drops a row's errors when the row is removed, so a
  //    stale message never outlives the thing it described.
  final pruned = errors.removeSubtree(TourFields.stop('a').key);
  print('${errors.length} -> ${pruned.length}'); // 2 -> 1
}
