// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rebuild_lab_schema.dart';

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

abstract interface class RebuildLabSchemaCopyWith<T> {
  T call({
    String? field0,
    String? field1,
    String? field2,
    String? field3,
    String? field4,
    String? field5,
    String? field6,
    String? field7,
    String? field8,
    String? field9,
    String? field10,
    String? field11,
    String? field12,
    String? field13,
    String? field14,
    String? field15,
    String? field16,
    String? field17,
    String? field18,
    String? field19,
    String? field20,
    String? field21,
    String? field22,
    String? field23,
  });
}

class _RebuildLabSchemaCopyWithImpl
    implements RebuildLabSchemaCopyWith<RebuildLabSchema> {
  const _RebuildLabSchemaCopyWithImpl(this._value);
  final RebuildLabSchema _value;

  @override
  RebuildLabSchema call({
    String? field0,
    String? field1,
    String? field2,
    String? field3,
    String? field4,
    String? field5,
    String? field6,
    String? field7,
    String? field8,
    String? field9,
    String? field10,
    String? field11,
    String? field12,
    String? field13,
    String? field14,
    String? field15,
    String? field16,
    String? field17,
    String? field18,
    String? field19,
    String? field20,
    String? field21,
    String? field22,
    String? field23,
  }) => RebuildLabSchema(
    field0: field0 ?? _value.field0,
    field1: field1 ?? _value.field1,
    field2: field2 ?? _value.field2,
    field3: field3 ?? _value.field3,
    field4: field4 ?? _value.field4,
    field5: field5 ?? _value.field5,
    field6: field6 ?? _value.field6,
    field7: field7 ?? _value.field7,
    field8: field8 ?? _value.field8,
    field9: field9 ?? _value.field9,
    field10: field10 ?? _value.field10,
    field11: field11 ?? _value.field11,
    field12: field12 ?? _value.field12,
    field13: field13 ?? _value.field13,
    field14: field14 ?? _value.field14,
    field15: field15 ?? _value.field15,
    field16: field16 ?? _value.field16,
    field17: field17 ?? _value.field17,
    field18: field18 ?? _value.field18,
    field19: field19 ?? _value.field19,
    field20: field20 ?? _value.field20,
    field21: field21 ?? _value.field21,
    field22: field22 ?? _value.field22,
    field23: field23 ?? _value.field23,
  );
}

class RebuildLabSchema {
  const RebuildLabSchema({
    this.field0 = '',
    this.field1 = '',
    this.field2 = '',
    this.field3 = '',
    this.field4 = '',
    this.field5 = '',
    this.field6 = '',
    this.field7 = '',
    this.field8 = '',
    this.field9 = '',
    this.field10 = '',
    this.field11 = '',
    this.field12 = '',
    this.field13 = '',
    this.field14 = '',
    this.field15 = '',
    this.field16 = '',
    this.field17 = '',
    this.field18 = '',
    this.field19 = '',
    this.field20 = '',
    this.field21 = '',
    this.field22 = '',
    this.field23 = '',
  });

  final String field0;
  final String field1;
  final String field2;
  final String field3;
  final String field4;
  final String field5;
  final String field6;
  final String field7;
  final String field8;
  final String field9;
  final String field10;
  final String field11;
  final String field12;
  final String field13;
  final String field14;
  final String field15;
  final String field16;
  final String field17;
  final String field18;
  final String field19;
  final String field20;
  final String field21;
  final String field22;
  final String field23;

  /// Creates a new [RebuildLabSchema] instance with auto-generated UUID if needed.
  factory RebuildLabSchema.create({
    String? field0,
    String? field1,
    String? field2,
    String? field3,
    String? field4,
    String? field5,
    String? field6,
    String? field7,
    String? field8,
    String? field9,
    String? field10,
    String? field11,
    String? field12,
    String? field13,
    String? field14,
    String? field15,
    String? field16,
    String? field17,
    String? field18,
    String? field19,
    String? field20,
    String? field21,
    String? field22,
    String? field23,
  }) {
    return RebuildLabSchema(
      field0: field0 ?? '',
      field1: field1 ?? '',
      field2: field2 ?? '',
      field3: field3 ?? '',
      field4: field4 ?? '',
      field5: field5 ?? '',
      field6: field6 ?? '',
      field7: field7 ?? '',
      field8: field8 ?? '',
      field9: field9 ?? '',
      field10: field10 ?? '',
      field11: field11 ?? '',
      field12: field12 ?? '',
      field13: field13 ?? '',
      field14: field14 ?? '',
      field15: field15 ?? '',
      field16: field16 ?? '',
      field17: field17 ?? '',
      field18: field18 ?? '',
      field19: field19 ?? '',
      field20: field20 ?? '',
      field21: field21 ?? '',
      field22: field22 ?? '',
      field23: field23 ?? '',
    );
  }

  RebuildLabSchemaCopyWith<RebuildLabSchema> get copyWith =>
      _RebuildLabSchemaCopyWithImpl(this);

  /// Converts this [RebuildLabSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'field0': field0,
    'field1': field1,
    'field2': field2,
    'field3': field3,
    'field4': field4,
    'field5': field5,
    'field6': field6,
    'field7': field7,
    'field8': field8,
    'field9': field9,
    'field10': field10,
    'field11': field11,
    'field12': field12,
    'field13': field13,
    'field14': field14,
    'field15': field15,
    'field16': field16,
    'field17': field17,
    'field18': field18,
    'field19': field19,
    'field20': field20,
    'field21': field21,
    'field22': field22,
    'field23': field23,
  };

  List<Object?> get _validationValues => [
    field0,
    field1,
    field2,
    field3,
    field4,
    field5,
    field6,
    field7,
    field8,
    field9,
    field10,
    field11,
    field12,
    field13,
    field14,
    field15,
    field16,
    field17,
    field18,
    field19,
    field20,
    field21,
    field22,
    field23,
  ];

  /// Validates this [RebuildLabSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _rebuildLabSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [RebuildLabSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _rebuildLabSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    RebuildLabSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [RebuildLabSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    RebuildLabSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [RebuildLabSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RebuildLabSchema &&
        field0 == other.field0 &&
        field1 == other.field1 &&
        field2 == other.field2 &&
        field3 == other.field3 &&
        field4 == other.field4 &&
        field5 == other.field5 &&
        field6 == other.field6 &&
        field7 == other.field7 &&
        field8 == other.field8 &&
        field9 == other.field9 &&
        field10 == other.field10 &&
        field11 == other.field11 &&
        field12 == other.field12 &&
        field13 == other.field13 &&
        field14 == other.field14 &&
        field15 == other.field15 &&
        field16 == other.field16 &&
        field17 == other.field17 &&
        field18 == other.field18 &&
        field19 == other.field19 &&
        field20 == other.field20 &&
        field21 == other.field21 &&
        field22 == other.field22 &&
        field23 == other.field23;
  }

  @override
  int get hashCode => Object.hashAll([
    field0,
    field1,
    field2,
    field3,
    field4,
    field5,
    field6,
    field7,
    field8,
    field9,
    field10,
    field11,
    field12,
    field13,
    field14,
    field15,
    field16,
    field17,
    field18,
    field19,
    field20,
    field21,
    field22,
    field23,
  ]);
}

abstract final class RebuildLabFields {
  static StrictFieldRef<RebuildLabSchema, String> get field0 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field0'),
        get: (x) => x.field0,
        set: (x, v) => x.copyWith(field0: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field1 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field1'),
        get: (x) => x.field1,
        set: (x, v) => x.copyWith(field1: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field2 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field2'),
        get: (x) => x.field2,
        set: (x, v) => x.copyWith(field2: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field3 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field3'),
        get: (x) => x.field3,
        set: (x, v) => x.copyWith(field3: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field4 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field4'),
        get: (x) => x.field4,
        set: (x, v) => x.copyWith(field4: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field5 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field5'),
        get: (x) => x.field5,
        set: (x, v) => x.copyWith(field5: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field6 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field6'),
        get: (x) => x.field6,
        set: (x, v) => x.copyWith(field6: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field7 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field7'),
        get: (x) => x.field7,
        set: (x, v) => x.copyWith(field7: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field8 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field8'),
        get: (x) => x.field8,
        set: (x, v) => x.copyWith(field8: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field9 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field9'),
        get: (x) => x.field9,
        set: (x, v) => x.copyWith(field9: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field10 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field10'),
        get: (x) => x.field10,
        set: (x, v) => x.copyWith(field10: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field11 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field11'),
        get: (x) => x.field11,
        set: (x, v) => x.copyWith(field11: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field12 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field12'),
        get: (x) => x.field12,
        set: (x, v) => x.copyWith(field12: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field13 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field13'),
        get: (x) => x.field13,
        set: (x, v) => x.copyWith(field13: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field14 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field14'),
        get: (x) => x.field14,
        set: (x, v) => x.copyWith(field14: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field15 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field15'),
        get: (x) => x.field15,
        set: (x, v) => x.copyWith(field15: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field16 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field16'),
        get: (x) => x.field16,
        set: (x, v) => x.copyWith(field16: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field17 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field17'),
        get: (x) => x.field17,
        set: (x, v) => x.copyWith(field17: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field18 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field18'),
        get: (x) => x.field18,
        set: (x, v) => x.copyWith(field18: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field19 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field19'),
        get: (x) => x.field19,
        set: (x, v) => x.copyWith(field19: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field20 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field20'),
        get: (x) => x.field20,
        set: (x, v) => x.copyWith(field20: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field21 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field21'),
        get: (x) => x.field21,
        set: (x, v) => x.copyWith(field21: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field22 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field22'),
        get: (x) => x.field22,
        set: (x, v) => x.copyWith(field22: v),
      );

  static StrictFieldRef<RebuildLabSchema, String> get field23 =>
      StrictFieldRef<RebuildLabSchema, String>.of(
        key: FieldKey.name('field23'),
        get: (x) => x.field23,
        set: (x, v) => x.copyWith(field23: v),
      );
}
