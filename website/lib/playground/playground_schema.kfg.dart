// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_element, sort_constructors_first, avoid_equals_and_hash_code_on_mutable_classes, specify_nonobvious_property_types

part of 'playground_schema.dart';

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

abstract interface class PlaygroundSchemaCopyWith<T> {
  T call({
    String? name,
    String? email,
    int? age,
    bool? newsletter,
    PlanTier? plan,
  });
}

class _PlaygroundSchemaCopyWithImpl
    implements PlaygroundSchemaCopyWith<PlaygroundSchema> {
  const _PlaygroundSchemaCopyWithImpl(this._value);
  final PlaygroundSchema _value;

  @override
  PlaygroundSchema call({
    String? name,
    String? email,
    Object? age = _unset,
    bool? newsletter,
    PlanTier? plan,
  }) => PlaygroundSchema(
    name: name ?? _value.name,
    email: email ?? _value.email,
    age: identical(age, _unset) ? _value.age : age as int?,
    newsletter: newsletter ?? _value.newsletter,
    plan: plan ?? _value.plan,
  );
}

class PlaygroundSchema {
  const PlaygroundSchema({
    this.name = '',
    this.email = '',
    this.age,
    this.newsletter = false,
    this.plan = PlanTier.free,
  });

  final String name;
  final String email;
  final int? age;
  final bool newsletter;
  final PlanTier plan;

  /// Creates a new [PlaygroundSchema] instance with auto-generated UUID if needed.
  factory PlaygroundSchema.create({
    String? name,
    String? email,
    int? age,
    bool? newsletter,
    PlanTier? plan,
  }) {
    return PlaygroundSchema(
      name: name ?? '',
      email: email ?? '',
      age: age,
      newsletter: newsletter ?? false,
      plan: plan ?? PlanTier.free,
    );
  }

  PlaygroundSchemaCopyWith<PlaygroundSchema> get copyWith =>
      _PlaygroundSchemaCopyWithImpl(this);

  /// Converts this [PlaygroundSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'name': name,
    'email': email,
    'age': age,
    'newsletter': newsletter,
    'plan': plan,
  };

  List<Object?> get _validationValues => [name, email, age, newsletter, plan];

  /// Validates this [PlaygroundSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _playgroundSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [PlaygroundSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _playgroundSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    PlaygroundSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [PlaygroundSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    PlaygroundSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [PlaygroundSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaygroundSchema &&
        name == other.name &&
        email == other.email &&
        age == other.age &&
        newsletter == other.newsletter &&
        plan == other.plan;
  }

  @override
  int get hashCode => Object.hash(name, email, age, newsletter, plan);
}

abstract final class PlaygroundFields {
  static StrictFieldRef<PlaygroundSchema, String> get name =>
      StrictFieldRef<PlaygroundSchema, String>.of(
        key: FieldKey.name('name'),
        get: (x) => x.name,
        set: (x, v) => x.copyWith(name: v),
      );

  static StrictFieldRef<PlaygroundSchema, String> get email =>
      StrictFieldRef<PlaygroundSchema, String>.of(
        key: FieldKey.name('email'),
        get: (x) => x.email,
        set: (x, v) => x.copyWith(email: v),
      );

  static StrictFieldRef<PlaygroundSchema, int?> get age =>
      StrictFieldRef<PlaygroundSchema, int?>.of(
        key: FieldKey.name('age'),
        get: (x) => x.age,
        set: (x, v) => x.copyWith(age: v),
      );

  static StrictFieldRef<PlaygroundSchema, bool> get newsletter =>
      StrictFieldRef<PlaygroundSchema, bool>.of(
        key: FieldKey.name('newsletter'),
        get: (x) => x.newsletter,
        set: (x, v) => x.copyWith(newsletter: v),
      );

  static StrictFieldRef<PlaygroundSchema, PlanTier> get plan =>
      StrictFieldRef<PlaygroundSchema, PlanTier>.of(
        key: FieldKey.name('plan'),
        get: (x) => x.plan,
        set: (x, v) => x.copyWith(plan: v),
      );
}
