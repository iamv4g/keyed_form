// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packing_schema.dart';

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

abstract interface class PackingSchemaCopyWith<T> {
  T call({List<PackingItemSchema>? items});
}

class _PackingSchemaCopyWithImpl
    implements PackingSchemaCopyWith<PackingSchema> {
  const _PackingSchemaCopyWithImpl(this._value);
  final PackingSchema _value;

  @override
  PackingSchema call({List<PackingItemSchema>? items}) =>
      PackingSchema(items: items ?? _value.items);
}

class PackingSchema {
  const PackingSchema({this.items = const []});

  final List<PackingItemSchema> items;

  /// Creates a new [PackingSchema] instance with auto-generated UUID if needed.
  factory PackingSchema.create({List<PackingItemSchema>? items}) {
    return PackingSchema(items: items ?? const []);
  }

  PackingSchemaCopyWith<PackingSchema> get copyWith =>
      _PackingSchemaCopyWithImpl(this);

  /// Converts this [PackingSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'items': items.map((e) => e.toMap()).toList(),
  };

  List<Object?> get _validationValues => [items.map((e) => e.toMap()).toList()];

  /// Validates this [PackingSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _packingSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [PackingSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _packingSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    PackingSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [PackingSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    PackingSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [PackingSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackingSchema && _listEquals(items, other.items);
  }

  @override
  int get hashCode => Object.hashAll(items);
}

abstract final class PackingFields {
  static StrictFieldRef<PackingSchema, List<PackingItemSchema>> get items =>
      StrictFieldRef<PackingSchema, List<PackingItemSchema>>.of(
        key: FieldKey.name('items'),
        get: (x) => x.items,
        set: (x, v) => x.copyWith(items: v),
      );

  /// Field references for the `items` row identified by [at].
  /// Affine — reads null / writes are a no-op if that row no longer exists.
  static ItemFieldRefs item(ItemRef at) =>
      ItemFieldRefs(items.at(at.item, (x) => x.clientId == at.item));
}

/// Identifies one `items` row by its clientId path: `item` = a `PackingItemSchema.clientId`.
/// Build it from your row objects, e.g. `(item: …)`.
typedef ItemRef = ({String item});

/// Field references for a [PackingItemSchema] within [PackingSchema].
final class ItemFieldRefs
    extends DelegatingFieldRef<PackingSchema, PackingItemSchema> {
  ItemFieldRefs(super.inner);

  /// `FieldRef` to `PackingItemFields.label`.
  FieldRef<PackingSchema, String> get label =>
      inner.then(PackingItemFields.label);

  /// `FieldRef` to `PackingItemFields.packed`.
  FieldRef<PackingSchema, bool> get packed =>
      inner.then(PackingItemFields.packed);
}

abstract interface class PackingItemSchemaCopyWith<T> {
  T call({String? clientId, String? label, bool? packed});
}

class _PackingItemSchemaCopyWithImpl
    implements PackingItemSchemaCopyWith<PackingItemSchema> {
  const _PackingItemSchemaCopyWithImpl(this._value);
  final PackingItemSchema _value;

  @override
  PackingItemSchema call({String? clientId, String? label, bool? packed}) =>
      PackingItemSchema(
        clientId: clientId ?? _value.clientId,
        label: label ?? _value.label,
        packed: packed ?? _value.packed,
      );
}

class PackingItemSchema implements KeyedRow {
  const PackingItemSchema({
    required this.clientId,
    this.label = '',
    this.packed = false,
  });

  final String clientId;
  final String label;
  final bool packed;

  /// Creates a new [PackingItemSchema] instance with auto-generated UUID if needed.
  factory PackingItemSchema.create({
    String? clientId,
    String? label,
    bool? packed,
  }) {
    return PackingItemSchema(
      clientId: clientId ?? const Uuid().v4(),
      label: label ?? '',
      packed: packed ?? false,
    );
  }

  PackingItemSchemaCopyWith<PackingItemSchema> get copyWith =>
      _PackingItemSchemaCopyWithImpl(this);

  /// Converts this [PackingItemSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'clientId': clientId,
    'label': label,
    'packed': packed,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackingItemSchema &&
        clientId == other.clientId &&
        label == other.label &&
        packed == other.packed;
  }

  @override
  int get hashCode => Object.hash(clientId, label, packed);
}

abstract final class PackingItemFields {
  static StrictFieldRef<PackingItemSchema, String> get label =>
      StrictFieldRef<PackingItemSchema, String>.of(
        key: FieldKey.name('label'),
        get: (x) => x.label,
        set: (x, v) => x.copyWith(label: v),
      );

  static StrictFieldRef<PackingItemSchema, bool> get packed =>
      StrictFieldRef<PackingItemSchema, bool>.of(
        key: FieldKey.name('packed'),
        get: (x) => x.packed,
        set: (x, v) => x.copyWith(packed: v),
      );
}
