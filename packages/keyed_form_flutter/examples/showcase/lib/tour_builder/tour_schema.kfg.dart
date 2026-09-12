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
  T call({
    String? title,
    TourCategory? category,
    int? maxGuests,
    bool? isPublic,
    List<StopSchema>? stops,
    String? notes,
  });
}

class _TourSchemaCopyWithImpl implements TourSchemaCopyWith<TourSchema> {
  const _TourSchemaCopyWithImpl(this._value);
  final TourSchema _value;

  @override
  TourSchema call({
    String? title,
    TourCategory? category,
    int? maxGuests,
    bool? isPublic,
    List<StopSchema>? stops,
    String? notes,
  }) => TourSchema(
    title: title ?? _value.title,
    category: category ?? _value.category,
    maxGuests: maxGuests ?? _value.maxGuests,
    isPublic: isPublic ?? _value.isPublic,
    stops: stops ?? _value.stops,
    notes: notes ?? _value.notes,
  );
}

class TourSchema {
  const TourSchema({
    this.title = '',
    this.category = TourCategory.culture,
    this.maxGuests = 8,
    this.isPublic = false,
    this.stops = const [],
    this.notes = '',
  });

  final String title;
  final TourCategory category;
  final int maxGuests;
  final bool isPublic;
  final List<StopSchema> stops;
  final String notes;

  /// Creates a new [TourSchema] instance with auto-generated UUID if needed.
  factory TourSchema.create({
    String? title,
    TourCategory? category,
    int? maxGuests,
    bool? isPublic,
    List<StopSchema>? stops,
    String? notes,
  }) {
    return TourSchema(
      title: title ?? '',
      category: category ?? TourCategory.culture,
      maxGuests: maxGuests ?? 8,
      isPublic: isPublic ?? false,
      stops: stops ?? const [],
      notes: notes ?? '',
    );
  }

  TourSchemaCopyWith<TourSchema> get copyWith => _TourSchemaCopyWithImpl(this);

  /// Converts this [TourSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'title': title,
    'category': category,
    'maxGuests': maxGuests,
    'isPublic': isPublic,
    'stops': stops.map((e) => e.toMap()).toList(),
    'notes': notes,
  };

  List<Object?> get _validationValues => [
    title,
    category,
    maxGuests,
    isPublic,
    stops.map((e) => e.toMap()).toList(),
    notes,
  ];

  /// Validates this [TourSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _tourSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [TourSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _tourSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    TourSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [TourSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    TourSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [TourSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TourSchema &&
        title == other.title &&
        category == other.category &&
        maxGuests == other.maxGuests &&
        isPublic == other.isPublic &&
        _listEquals(stops, other.stops) &&
        notes == other.notes;
  }

  @override
  int get hashCode => Object.hash(
    title,
    category,
    maxGuests,
    isPublic,
    Object.hashAll(stops),
    notes,
  );
}

abstract final class TourFields {
  static StrictFieldRef<TourSchema, String> get title =>
      StrictFieldRef<TourSchema, String>.of(
        key: FieldKey.name('title'),
        get: (x) => x.title,
        set: (x, v) => x.copyWith(title: v),
      );

  static StrictFieldRef<TourSchema, TourCategory> get category =>
      StrictFieldRef<TourSchema, TourCategory>.of(
        key: FieldKey.name('category'),
        get: (x) => x.category,
        set: (x, v) => x.copyWith(category: v),
      );

  static StrictFieldRef<TourSchema, int> get maxGuests =>
      StrictFieldRef<TourSchema, int>.of(
        key: FieldKey.name('maxGuests'),
        get: (x) => x.maxGuests,
        set: (x, v) => x.copyWith(maxGuests: v),
      );

  static StrictFieldRef<TourSchema, bool> get isPublic =>
      StrictFieldRef<TourSchema, bool>.of(
        key: FieldKey.name('isPublic'),
        get: (x) => x.isPublic,
        set: (x, v) => x.copyWith(isPublic: v),
      );

  static StrictFieldRef<TourSchema, List<StopSchema>> get stops =>
      StrictFieldRef<TourSchema, List<StopSchema>>.of(
        key: FieldKey.name('stops'),
        get: (x) => x.stops,
        set: (x, v) => x.copyWith(stops: v),
      );

  static StrictFieldRef<TourSchema, String> get notes =>
      StrictFieldRef<TourSchema, String>.of(
        key: FieldKey.name('notes'),
        get: (x) => x.notes,
        set: (x, v) => x.copyWith(notes: v),
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
}

abstract interface class StopSchemaCopyWith<T> {
  T call({String? clientId, String? city, int? nights});
}

class _StopSchemaCopyWithImpl implements StopSchemaCopyWith<StopSchema> {
  const _StopSchemaCopyWithImpl(this._value);
  final StopSchema _value;

  @override
  StopSchema call({String? clientId, String? city, int? nights}) => StopSchema(
    clientId: clientId ?? _value.clientId,
    city: city ?? _value.city,
    nights: nights ?? _value.nights,
  );
}

class StopSchema implements KeyedRow {
  const StopSchema({required this.clientId, this.city = '', this.nights = 2});

  final String clientId;
  final String city;
  final int nights;

  /// Creates a new [StopSchema] instance with auto-generated UUID if needed.
  factory StopSchema.create({String? clientId, String? city, int? nights}) {
    return StopSchema(
      clientId: clientId ?? const Uuid().v4(),
      city: city ?? '',
      nights: nights ?? 2,
    );
  }

  StopSchemaCopyWith<StopSchema> get copyWith => _StopSchemaCopyWithImpl(this);

  /// Converts this [StopSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'clientId': clientId,
    'city': city,
    'nights': nights,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StopSchema &&
        clientId == other.clientId &&
        city == other.city &&
        nights == other.nights;
  }

  @override
  int get hashCode => Object.hash(clientId, city, nights);
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
}
