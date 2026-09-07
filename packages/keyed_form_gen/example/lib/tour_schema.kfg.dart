// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_schema.dart';
// ignore_for_file: type=lint, unused_element, sort_constructors_first, avoid_equals_and_hash_code_on_mutable_classes, specify_nonobvious_property_types

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

int _mapHash(Map<Object?, Object?>? map) {
  if (map == null) return 0;
  var hash = 0;
  for (final entry in map.entries) {
    hash ^= Object.hash(entry.key, entry.value);
  }
  return hash;
}

const _unset = Object();

abstract interface class TourSchemaCopyWith<T> {
  T call({String? title, List<StopSchema>? stops});
}

class _TourSchemaCopyWithImpl implements TourSchemaCopyWith<TourSchema> {
  const _TourSchemaCopyWithImpl(this._value);
  final TourSchema _value;

  @override
  TourSchema call({String? title, List<StopSchema>? stops}) =>
      TourSchema(title: title ?? _value.title, stops: stops ?? _value.stops);
}

class TourSchema {
  const TourSchema({this.title = '', this.stops = const []});

  final String title;
  final List<StopSchema> stops;

  /// Creates a new [TourSchema] instance with auto-generated UUID if needed.
  factory TourSchema.create({String? title, List<StopSchema>? stops}) {
    return TourSchema(title: title ?? '', stops: stops ?? const []);
  }

  TourSchemaCopyWith<TourSchema> get copyWith => _TourSchemaCopyWithImpl(this);

  /// Converts this [TourSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'title': title,
    'stops': stops.map((e) => e.toMap()).toList(),
  };

  /// Synchronously validates this [TourSchema] against its schema.
  FieldErrors<String> validate() => tourSchema.validateMap(toMap());

  /// Asynchronously validates this [TourSchema] against its schema.
  Future<FieldErrors<String>> validateAsync() =>
      tourSchema.validateMapAsync(toMap());

  /// Static validator function for [TourSchema], suitable for Riverpod or callbacks.
  static FieldErrors<String> validateData(TourSchema schema) =>
      schema.validate();

  /// Static async validator function for [TourSchema].
  static Future<FieldErrors<String>> validateDataAsync(TourSchema schema) =>
      schema.validateAsync();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TourSchema &&
        title == other.title &&
        _listEquals(stops, other.stops);
  }

  @override
  int get hashCode => Object.hash(title, Object.hashAll(stops));
}

abstract final class TourFields {
  static StrictFieldRef<TourSchema, String> get title =>
      StrictFieldRef<TourSchema, String>.of(
        key: FieldKey.name('title'),
        get: (x) => x.title,
        set: (x, v) => x.copyWith(title: v),
      );

  static StrictFieldRef<TourSchema, List<StopSchema>> get stops =>
      StrictFieldRef<TourSchema, List<StopSchema>>.of(
        key: FieldKey.name('stops'),
        get: (x) => x.stops,
        set: (x, v) => x.copyWith(stops: v),
      );

  /// Field references for the `stops` row identified by [at].
  /// Affine — reads null / writes are a no-op if that row no longer exists.
  static StopFieldRefs stop(StopRef at) =>
      StopFieldRefs(stops.at(at.stop, (x) => x.clientId == at.stop));
}

/// Identifies one `stops` row by its clientId path: `stop` = a `StopSchema.clientId`.
/// Build it from your row objects, e.g. `(stop: …)`.
typedef StopRef = ({String stop});

/// Field references for a [StopSchema] within [TourSchema].
final class StopFieldRefs extends DelegatingFieldRef<TourSchema, StopSchema> {
  StopFieldRefs(super.inner);

  /// `FieldRef` to `StopFields.city`.
  FieldRef<TourSchema, String> get city => inner.then(StopFields.city);

  /// `FieldRef` to `StopFields.nights`.
  FieldRef<TourSchema, int> get nights => inner.then(StopFields.nights);

  /// `FieldRef` to `StopFields.note`.
  FieldRef<TourSchema, String?> get note => inner.then(StopFields.note);
}

abstract interface class StopSchemaCopyWith<T> {
  T call({String? clientId, String? city, int? nights, String? note});
}

class _StopSchemaCopyWithImpl implements StopSchemaCopyWith<StopSchema> {
  const _StopSchemaCopyWithImpl(this._value);
  final StopSchema _value;

  @override
  StopSchema call({
    String? clientId,
    String? city,
    int? nights,
    Object? note = _unset,
  }) => StopSchema(
    clientId: clientId ?? _value.clientId,
    city: city ?? _value.city,
    nights: nights ?? _value.nights,
    note: identical(note, _unset) ? _value.note : note as String?,
  );
}

class StopSchema implements KeyedRow {
  const StopSchema({
    required this.clientId,
    this.city = '',
    this.nights = 1,
    this.note,
  });

  final String clientId;
  final String city;
  final int nights;
  final String? note;

  /// Creates a new [StopSchema] instance with auto-generated UUID if needed.
  factory StopSchema.create({
    String? clientId,
    String? city,
    int? nights,
    String? note,
  }) {
    return StopSchema(
      clientId: clientId ?? const Uuid().v4(),
      city: city ?? '',
      nights: nights ?? 1,
      note: note,
    );
  }

  StopSchemaCopyWith<StopSchema> get copyWith => _StopSchemaCopyWithImpl(this);

  /// Converts this [StopSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'clientId': clientId,
    'city': city,
    'nights': nights,
    'note': note,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StopSchema &&
        clientId == other.clientId &&
        city == other.city &&
        nights == other.nights &&
        note == other.note;
  }

  @override
  int get hashCode => Object.hash(clientId, city, nights, note);
}

abstract final class StopFields {
  static StrictFieldRef<StopSchema, String> get city =>
      StrictFieldRef<StopSchema, String>.of(
        key: FieldKey.name('city'),
        get: (x) => x.city,
        set: (x, v) => x.copyWith(city: v),
      );

  static StrictFieldRef<StopSchema, int> get nights =>
      StrictFieldRef<StopSchema, int>.of(
        key: FieldKey.name('nights'),
        get: (x) => x.nights,
        set: (x, v) => x.copyWith(nights: v),
      );

  static StrictFieldRef<StopSchema, String?> get note =>
      StrictFieldRef<StopSchema, String?>.of(
        key: FieldKey.name('note'),
        get: (x) => x.note,
        set: (x, v) => x.copyWith(note: v),
      );
}
