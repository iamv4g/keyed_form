// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_schema.dart';

// **************************************************************************
// KeyedFormGenerator
// **************************************************************************

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
    List<HotelSchema>? hotels,
    List<int>? confirmedDays,
    Map<String, int>? dayNotes,
    String? ownerNote,
  });
}

class _TourSchemaCopyWithImpl implements TourSchemaCopyWith<TourSchema> {
  const _TourSchemaCopyWithImpl(this._value);
  final TourSchema _value;

  @override
  TourSchema call({
    String? title,
    List<HotelSchema>? hotels,
    List<int>? confirmedDays,
    Map<String, int>? dayNotes,
    Object? ownerNote = _unset,
  }) => TourSchema(
    title: title ?? _value.title,
    hotels: hotels ?? _value.hotels,
    confirmedDays: confirmedDays ?? _value.confirmedDays,
    dayNotes: dayNotes ?? _value.dayNotes,
    ownerNote: identical(ownerNote, _unset)
        ? _value.ownerNote
        : ownerNote as String?,
  );
}

class TourSchema {
  const TourSchema({
    this.title = '',
    this.hotels = const [],
    this.confirmedDays = const [],
    this.dayNotes = const {},
    this.ownerNote,
  });

  final String title;
  final List<HotelSchema> hotels;
  final List<int> confirmedDays;
  final Map<String, int> dayNotes;
  final String? ownerNote;

  /// Creates a new [TourSchema] instance with auto-generated UUID if needed.
  factory TourSchema.create({
    String? title,
    List<HotelSchema>? hotels,
    List<int>? confirmedDays,
    Map<String, int>? dayNotes,
    String? ownerNote,
  }) {
    return TourSchema(
      title: title ?? '',
      hotels: hotels ?? const [],
      confirmedDays: confirmedDays ?? const [],
      dayNotes: dayNotes ?? const {},
      ownerNote: ownerNote,
    );
  }

  TourSchemaCopyWith<TourSchema> get copyWith => _TourSchemaCopyWithImpl(this);

  /// Converts this [TourSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'title': title,
    'hotels': hotels.map((e) => e.toMap()).toList(),
    'confirmedDays': confirmedDays,
    'dayNotes': dayNotes,
    'ownerNote': ownerNote,
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
        _listEquals(hotels, other.hotels) &&
        _listEquals(confirmedDays, other.confirmedDays) &&
        _mapEquals(dayNotes, other.dayNotes) &&
        ownerNote == other.ownerNote;
  }

  @override
  int get hashCode => Object.hash(
    title,
    Object.hashAll(hotels),
    Object.hashAll(confirmedDays),
    _mapHash(dayNotes),
    ownerNote,
  );
}

abstract final class TourFields {
  static Lens<TourSchema, String> get title => Lens.of(
    key: FieldKey.name('title'),
    get: (x) => x.title,
    set: (x, v) => x.copyWith(title: v),
  );

  static Lens<TourSchema, List<HotelSchema>> get hotels => Lens.of(
    key: FieldKey.name('hotels'),
    get: (x) => x.hotels,
    set: (x, v) => x.copyWith(hotels: v),
  );

  static Lens<TourSchema, List<int>> get confirmedDays => Lens.of(
    key: FieldKey.name('confirmedDays'),
    get: (x) => x.confirmedDays,
    set: (x, v) => x.copyWith(confirmedDays: v),
  );

  static Lens<TourSchema, Map<String, int>> get dayNotes => Lens.of(
    key: FieldKey.name('dayNotes'),
    get: (x) => x.dayNotes,
    set: (x, v) => x.copyWith(dayNotes: v),
  );

  static Lens<TourSchema, String?> get ownerNote => Lens.of(
    key: FieldKey.name('ownerNote'),
    get: (x) => x.ownerNote,
    set: (x, v) => x.copyWith(ownerNote: v),
  );

  /// Field references for the `hotels` row identified by [at].
  /// Affine — reads null / writes are a no-op if that row no longer exists.
  static HotelFieldRefs hotel(HotelRef at) =>
      HotelFieldRefs(hotels.at(at.hotel, (x) => x.clientId == at.hotel));
}

/// Identifies one `hotels` row by its clientId path: `hotel` = a `HotelSchema.clientId`.
/// Build it from your row objects, e.g. `(hotel: …)`.
typedef HotelRef = ({String hotel});

/// Field references for a [HotelSchema] within [TourSchema].
final class HotelFieldRefs extends AffineLens<TourSchema, HotelSchema> {
  HotelFieldRefs(this._self);

  final AffineLens<TourSchema, HotelSchema> _self;

  @override
  FieldKey get key => _self.key;

  @override
  Opt<HotelSchema> find(TourSchema root) => _self.find(root);

  @override
  TourSchema set(TourSchema root, HotelSchema value) => _self.set(root, value);

  /// `FieldRef` to `HotelFields.hotelName`.
  FieldRef<TourSchema, String> get hotelName =>
      _self.then(HotelFields.hotelName);

  /// `FieldRef` to `HotelFields.hotelPrice`.
  FieldRef<TourSchema, String?> get hotelPrice =>
      _self.then(HotelFields.hotelPrice);

  /// `FieldRef` to `HotelFields.prefectureId`.
  FieldRef<TourSchema, int?> get prefectureId =>
      _self.then(HotelFields.prefectureId);
}

abstract interface class HotelSchemaCopyWith<T> {
  T call({
    String? clientId,
    String? hotelName,
    String? hotelPrice,
    int? prefectureId,
  });
}

class _HotelSchemaCopyWithImpl implements HotelSchemaCopyWith<HotelSchema> {
  const _HotelSchemaCopyWithImpl(this._value);
  final HotelSchema _value;

  @override
  HotelSchema call({
    String? clientId,
    String? hotelName,
    Object? hotelPrice = _unset,
    Object? prefectureId = _unset,
  }) => HotelSchema(
    clientId: clientId ?? _value.clientId,
    hotelName: hotelName ?? _value.hotelName,
    hotelPrice: identical(hotelPrice, _unset)
        ? _value.hotelPrice
        : hotelPrice as String?,
    prefectureId: identical(prefectureId, _unset)
        ? _value.prefectureId
        : prefectureId as int?,
  );
}

class HotelSchema implements KeyedRow {
  const HotelSchema({
    required this.clientId,
    this.hotelName = '',
    this.hotelPrice,
    this.prefectureId,
  });

  final String clientId;
  final String hotelName;
  final String? hotelPrice;
  final int? prefectureId;

  /// Creates a new [HotelSchema] instance with auto-generated UUID if needed.
  factory HotelSchema.create({
    String? clientId,
    String? hotelName,
    String? hotelPrice,
    int? prefectureId,
  }) {
    return HotelSchema(
      clientId: clientId ?? const Uuid().v4(),
      hotelName: hotelName ?? '',
      hotelPrice: hotelPrice,
      prefectureId: prefectureId,
    );
  }

  HotelSchemaCopyWith<HotelSchema> get copyWith =>
      _HotelSchemaCopyWithImpl(this);

  /// Converts this [HotelSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'clientId': clientId,
    'hotelName': hotelName,
    'hotelPrice': hotelPrice,
    'prefectureId': prefectureId,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HotelSchema &&
        clientId == other.clientId &&
        hotelName == other.hotelName &&
        hotelPrice == other.hotelPrice &&
        prefectureId == other.prefectureId;
  }

  @override
  int get hashCode =>
      Object.hash(clientId, hotelName, hotelPrice, prefectureId);
}

abstract final class HotelFields {
  static Lens<HotelSchema, String> get hotelName => Lens.of(
    key: FieldKey.name('hotelName'),
    get: (x) => x.hotelName,
    set: (x, v) => x.copyWith(hotelName: v),
  );

  static Lens<HotelSchema, String?> get hotelPrice => Lens.of(
    key: FieldKey.name('hotelPrice'),
    get: (x) => x.hotelPrice,
    set: (x, v) => x.copyWith(hotelPrice: v),
  );

  static Lens<HotelSchema, int?> get prefectureId => Lens.of(
    key: FieldKey.name('prefectureId'),
    get: (x) => x.prefectureId,
    set: (x, v) => x.copyWith(prefectureId: v),
  );
}
