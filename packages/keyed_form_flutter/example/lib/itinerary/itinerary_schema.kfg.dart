// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_schema.dart';

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

abstract interface class ItinerarySchemaCopyWith<T> {
  T call({List<DaySchema>? days});
}

class _ItinerarySchemaCopyWithImpl
    implements ItinerarySchemaCopyWith<ItinerarySchema> {
  const _ItinerarySchemaCopyWithImpl(this._value);
  final ItinerarySchema _value;

  @override
  ItinerarySchema call({List<DaySchema>? days}) =>
      ItinerarySchema(days: days ?? _value.days);
}

class ItinerarySchema {
  const ItinerarySchema({this.days = const []});

  final List<DaySchema> days;

  /// Creates a new [ItinerarySchema] instance with auto-generated UUID if needed.
  factory ItinerarySchema.create({List<DaySchema>? days}) {
    return ItinerarySchema(days: days ?? const []);
  }

  ItinerarySchemaCopyWith<ItinerarySchema> get copyWith =>
      _ItinerarySchemaCopyWithImpl(this);

  /// Converts this [ItinerarySchema] to a Map representation.
  Map<String, Object?> toMap() => {'days': days.map((e) => e.toMap()).toList()};

  List<Object?> get _validationValues => [days.map((e) => e.toMap()).toList()];

  /// Validates this [ItinerarySchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _itinerarySchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [ItinerarySchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _itinerarySchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    ItinerarySchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [ItinerarySchema].
  static Future<FieldErrors<String>> validateDataAsync(
    ItinerarySchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [ItinerarySchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItinerarySchema && _listEquals(days, other.days);
  }

  @override
  int get hashCode => Object.hashAll(days);
}

abstract final class ItineraryFields {
  static StrictFieldRef<ItinerarySchema, List<DaySchema>> get days =>
      StrictFieldRef<ItinerarySchema, List<DaySchema>>.of(
        key: FieldKey.name('days'),
        get: (x) => x.days,
        set: (x, v) => x.copyWith(days: v),
      );

  /// Field references for the `days` row identified by [at].
  /// Affine — reads null / writes are a no-op if that row no longer exists.
  static DayFieldRefs day(DayRef at) =>
      DayFieldRefs(days.at(at.day, (x) => x.clientId == at.day));

  /// The `activities` list on the `day` row [at] addresses.
  static FieldRef<ItinerarySchema, List<ActivitySchema>> dayActivities(
    DayRef at,
  ) => day(at).asFieldRef.then(DayFields.activities);

  /// Field references for the `activities` row identified by [at].
  /// Affine — reads null / writes are a no-op if that row no longer exists.
  static ActivityFieldRefs activity(ActivityRef at) => ActivityFieldRefs(
    dayActivities((
      day: at.day,
    )).at(at.activity, (x) => x.clientId == at.activity),
  );
}

/// Identifies one `days` row by its clientId path: `day` = a `DaySchema.clientId`.
/// Build it from your row objects, e.g. `(day: …)`.
typedef DayRef = ({String day});

/// Identifies one `activities` row by its clientId path: `day` = a `DaySchema.clientId`, `activity` = a `ActivitySchema.clientId`.
/// Build it from your row objects, e.g. `(day: …, activity: …)`.
typedef ActivityRef = ({String day, String activity});

/// Field references for a [DaySchema] within [ItinerarySchema].
final class DayFieldRefs
    extends DelegatingFieldRef<ItinerarySchema, DaySchema> {
  DayFieldRefs(super.inner);

  /// `FieldRef` to `DayFields.label`.
  FieldRef<ItinerarySchema, String> get label => inner.then(DayFields.label);
}

/// Field references for a [ActivitySchema] within [ItinerarySchema].
final class ActivityFieldRefs
    extends DelegatingFieldRef<ItinerarySchema, ActivitySchema> {
  ActivityFieldRefs(super.inner);

  /// Narrows to the `sightseeing` variant ([SightseeingActivitySchema]) — affine: null / no-op when this ActivitySchema is a different variant.
  SightseeingActivityFieldRefs get asSightseeing =>
      SightseeingActivityFieldRefs(inner.narrow(_ActivityVariants.sightseeing));

  /// Narrows to the `meal` variant ([MealActivitySchema]) — affine: null / no-op when this ActivitySchema is a different variant.
  MealActivityFieldRefs get asMeal =>
      MealActivityFieldRefs(inner.narrow(_ActivityVariants.meal));
}

/// Field references for a [SightseeingActivitySchema] within [ItinerarySchema].
final class SightseeingActivityFieldRefs
    extends DelegatingFieldRef<ItinerarySchema, SightseeingActivitySchema> {
  SightseeingActivityFieldRefs(super.inner);

  /// `FieldRef` to `SightseeingActivityFields.place`.
  FieldRef<ItinerarySchema, String> get place =>
      inner.then(SightseeingActivityFields.place);
}

/// Field references for a [MealActivitySchema] within [ItinerarySchema].
final class MealActivityFieldRefs
    extends DelegatingFieldRef<ItinerarySchema, MealActivitySchema> {
  MealActivityFieldRefs(super.inner);

  /// `FieldRef` to `MealActivityFields.restaurant`.
  FieldRef<ItinerarySchema, String> get restaurant =>
      inner.then(MealActivityFields.restaurant);
}

abstract interface class DaySchemaCopyWith<T> {
  T call({String? clientId, String? label, List<ActivitySchema>? activities});
}

class _DaySchemaCopyWithImpl implements DaySchemaCopyWith<DaySchema> {
  const _DaySchemaCopyWithImpl(this._value);
  final DaySchema _value;

  @override
  DaySchema call({
    String? clientId,
    String? label,
    List<ActivitySchema>? activities,
  }) => DaySchema(
    clientId: clientId ?? _value.clientId,
    label: label ?? _value.label,
    activities: activities ?? _value.activities,
  );
}

class DaySchema implements KeyedRow {
  const DaySchema({
    required this.clientId,
    this.label = '',
    this.activities = const [],
  });

  final String clientId;
  final String label;
  final List<ActivitySchema> activities;

  /// Creates a new [DaySchema] instance with auto-generated UUID if needed.
  factory DaySchema.create({
    String? clientId,
    String? label,
    List<ActivitySchema>? activities,
  }) {
    return DaySchema(
      clientId: clientId ?? const Uuid().v4(),
      label: label ?? '',
      activities: activities ?? const [],
    );
  }

  DaySchemaCopyWith<DaySchema> get copyWith => _DaySchemaCopyWithImpl(this);

  /// Converts this [DaySchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'clientId': clientId,
    'label': label,
    'activities': activities.map((e) => e.toMap()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DaySchema &&
        clientId == other.clientId &&
        label == other.label &&
        _listEquals(activities, other.activities);
  }

  @override
  int get hashCode => Object.hash(clientId, label, Object.hashAll(activities));
}

abstract final class DayFields {
  static StrictFieldRef<DaySchema, String> get label =>
      StrictFieldRef<DaySchema, String>.of(
        key: FieldKey.name('label'),
        get: (x) => x.label,
        set: (x, v) => x.copyWith(label: v),
      );

  static StrictFieldRef<DaySchema, List<ActivitySchema>> get activities =>
      StrictFieldRef<DaySchema, List<ActivitySchema>>.of(
        key: FieldKey.name('activities'),
        get: (x) => x.activities,
        set: (x, v) => x.copyWith(activities: v),
      );
}

abstract interface class ActivitySchemaCopyWith<T> {
  T call({String? clientId});
}

class _ActivitySchemaCopyWithImpl
    implements ActivitySchemaCopyWith<ActivitySchema> {
  const _ActivitySchemaCopyWithImpl(this._value);
  final ActivitySchema _value;

  @override
  ActivitySchema call({String? clientId}) => switch (_value) {
    SightseeingActivitySchema x => x.copyWith(clientId: clientId ?? x.clientId),
    MealActivitySchema x => x.copyWith(clientId: clientId ?? x.clientId),
  };
}

sealed class ActivitySchema implements KeyedRow {
  const ActivitySchema({required this.clientId});

  final String clientId;

  String get kind;

  ActivitySchemaCopyWith<ActivitySchema> get copyWith =>
      _ActivitySchemaCopyWithImpl(this);

  Map<String, Object?> toMap() => switch (this) {
    SightseeingActivitySchema x => x.toMap(),
    MealActivitySchema x => x.toMap(),
  };

  FieldErrors<String> validate([FieldKey? scope]) => switch (this) {
    SightseeingActivitySchema x => x.validate(scope),
    MealActivitySchema x => x.validate(scope),
  };

  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      switch (this) {
        SightseeingActivitySchema x => x.validateAsync(scope),
        MealActivitySchema x => x.validateAsync(scope),
      };
}

abstract final class _ActivityVariants {
  static final sightseeing =
      VariantRef<ActivitySchema, SightseeingActivitySchema>.type();
  static final meal = VariantRef<ActivitySchema, MealActivitySchema>.type();
}

abstract final class ActivityFields {}

abstract interface class SightseeingActivitySchemaCopyWith<T>
    implements ActivitySchemaCopyWith<T> {
  T call({String? clientId, String? place});
}

class _SightseeingActivitySchemaCopyWithImpl
    implements SightseeingActivitySchemaCopyWith<SightseeingActivitySchema> {
  const _SightseeingActivitySchemaCopyWithImpl(this._value);
  final SightseeingActivitySchema _value;

  @override
  SightseeingActivitySchema call({String? clientId, String? place}) =>
      SightseeingActivitySchema(
        clientId: clientId ?? _value.clientId,
        place: place ?? _value.place,
      );
}

class SightseeingActivitySchema extends ActivitySchema {
  const SightseeingActivitySchema({required super.clientId, this.place = ''});

  final String place;

  @override
  String get kind => 'sightseeing';

  /// Creates a new [SightseeingActivitySchema] instance with auto-generated UUID if needed.
  factory SightseeingActivitySchema.create({String? clientId, String? place}) {
    return SightseeingActivitySchema(
      clientId: clientId ?? const Uuid().v4(),
      place: place ?? '',
    );
  }

  @override
  SightseeingActivitySchemaCopyWith<SightseeingActivitySchema> get copyWith =>
      _SightseeingActivitySchemaCopyWithImpl(this);

  @override
  Map<String, Object?> toMap() => {
    'kind': kind,
    'clientId': clientId,
    'place': place,
  };

  List<Object?> get _validationValues => [place];

  @override
  FieldErrors<String> validate([FieldKey? scope]) =>
      _itinerarySchema.validateValues(_validationValues, scope: scope);

  @override
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _itinerarySchema.validateValuesAsync(_validationValues, scope: scope);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SightseeingActivitySchema &&
        clientId == other.clientId &&
        place == other.place;
  }

  @override
  int get hashCode => Object.hash(clientId, place);
}

abstract final class SightseeingActivityFields {
  static StrictFieldRef<SightseeingActivitySchema, String> get place =>
      StrictFieldRef<SightseeingActivitySchema, String>.of(
        key: FieldKey.name('place'),
        get: (x) => x.place,
        set: (x, v) => x.copyWith(place: v),
      );
}

abstract interface class MealActivitySchemaCopyWith<T>
    implements ActivitySchemaCopyWith<T> {
  T call({String? clientId, String? restaurant});
}

class _MealActivitySchemaCopyWithImpl
    implements MealActivitySchemaCopyWith<MealActivitySchema> {
  const _MealActivitySchemaCopyWithImpl(this._value);
  final MealActivitySchema _value;

  @override
  MealActivitySchema call({String? clientId, String? restaurant}) =>
      MealActivitySchema(
        clientId: clientId ?? _value.clientId,
        restaurant: restaurant ?? _value.restaurant,
      );
}

class MealActivitySchema extends ActivitySchema {
  const MealActivitySchema({required super.clientId, this.restaurant = ''});

  final String restaurant;

  @override
  String get kind => 'meal';

  /// Creates a new [MealActivitySchema] instance with auto-generated UUID if needed.
  factory MealActivitySchema.create({String? clientId, String? restaurant}) {
    return MealActivitySchema(
      clientId: clientId ?? const Uuid().v4(),
      restaurant: restaurant ?? '',
    );
  }

  @override
  MealActivitySchemaCopyWith<MealActivitySchema> get copyWith =>
      _MealActivitySchemaCopyWithImpl(this);

  @override
  Map<String, Object?> toMap() => {
    'kind': kind,
    'clientId': clientId,
    'restaurant': restaurant,
  };

  List<Object?> get _validationValues => [restaurant];

  @override
  FieldErrors<String> validate([FieldKey? scope]) =>
      _itinerarySchema.validateValues(_validationValues, scope: scope);

  @override
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _itinerarySchema.validateValuesAsync(_validationValues, scope: scope);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealActivitySchema &&
        clientId == other.clientId &&
        restaurant == other.restaurant;
  }

  @override
  int get hashCode => Object.hash(clientId, restaurant);
}

abstract final class MealActivityFields {
  static StrictFieldRef<MealActivitySchema, String> get restaurant =>
      StrictFieldRef<MealActivitySchema, String>.of(
        key: FieldKey.name('restaurant'),
        get: (x) => x.restaurant,
        set: (x, v) => x.copyWith(restaurant: v),
      );
}
