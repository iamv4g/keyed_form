import 'package:keyed_form/keyed_form.dart';

/// A tiny immutable aggregate — a trip with a name and a list of stops — used
/// to exercise [KeyedFormController] without pulling in `keyed_form_gen`.

class Trip {
  const Trip({this.name = '', this.days = 0, this.stops = const []});

  final String name;
  final int days;
  final List<Stop> stops;

  Trip copyWith({String? name, int? days, List<Stop>? stops}) => Trip(
    name: name ?? this.name,
    days: days ?? this.days,
    stops: stops ?? this.stops,
  );

  @override
  bool operator ==(Object other) =>
      other is Trip &&
      other.name == name &&
      other.days == days &&
      _listEq(other.stops, stops);

  @override
  int get hashCode => Object.hash(name, days, Object.hashAll(stops));
}

class Stop implements KeyedRow {
  const Stop({required this.clientId, this.label = '', this.nights = 1});

  @override
  final String clientId;
  final String label;
  final int nights;

  Stop copyWith({String? label, int? nights}) => Stop(
    clientId: clientId,
    label: label ?? this.label,
    nights: nights ?? this.nights,
  );

  @override
  bool operator ==(Object other) =>
      other is Stop &&
      other.clientId == clientId &&
      other.label == label &&
      other.nights == nights;

  @override
  int get hashCode => Object.hash(clientId, label, nights);
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// --- lenses (hand-written stand-ins for generated `<Root>Fields`) ------------

abstract final class TripFields {
  static final Lens<Trip, String> name = Lens.of(
    key: FieldKey.name('name'),
    get: (t) => t.name,
    set: (t, v) => t.copyWith(name: v),
  );

  static final Lens<Trip, int> days = Lens.of(
    key: FieldKey.name('days'),
    get: (t) => t.days,
    set: (t, v) => t.copyWith(days: v),
  );

  static final Lens<Trip, List<Stop>> stops = Lens.of(
    key: FieldKey.name('stops'),
    get: (t) => t.stops,
    set: (t, v) => t.copyWith(stops: v),
  );

  static AffineLens<Trip, Stop> stop(String id) =>
      stops.at(id, (s) => s.clientId == id);

  static AffineLens<Trip, String> stopLabel(String id) =>
      stop(id).then(
        Lens.of(
          key: FieldKey.name('label'),
          get: (s) => s.label,
          set: (s, v) => s.copyWith(label: v),
        ),
      );

  static AffineLens<Trip, int> stopNights(String id) =>
      stop(id).then(
        Lens.of(
          key: FieldKey.name('nights'),
          get: (s) => s.nights,
          set: (s, v) => s.copyWith(nights: v),
        ),
      );
}

// --- resolvers -------------------------------------------------------------

/// Whole-draft: name required, days must be > 0, every stop label required.
FieldErrors<String> validateTrip(Trip trip, FieldKey? scope) {
  final errors = <FieldKey, String>{};
  if (scope == null || scope.contains(TripFields.name.key)) {
    if (trip.name.isEmpty) errors[TripFields.name.key] = 'name.required';
  }
  if (scope == null || scope.contains(TripFields.days.key)) {
    if (trip.days <= 0) errors[TripFields.days.key] = 'days.positive';
  }
  for (final stop in trip.stops) {
    final labelKey = TripFields.stopLabel(stop.clientId).key;
    if (scope != null && !scope.contains(labelKey)) continue;
    if (stop.label.isEmpty) errors[labelKey] = 'label.required';
  }
  return FieldErrors(errors);
}

/// Per-stop scope: `stops.[id]`.
FieldKey? stopScopeOf(FieldKey writtenKey) {
  final segs = writtenKey.segments;
  if (segs.length >= 2 &&
      segs[0] == const NameSegment('stops') &&
      segs[1] is IdSegment) {
    return writtenKey.prefix(2);
  }
  return null;
}
