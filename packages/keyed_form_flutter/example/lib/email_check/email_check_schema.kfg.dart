// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_element, sort_constructors_first, avoid_equals_and_hash_code_on_mutable_classes, specify_nonobvious_property_types

part of 'email_check_schema.dart';

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

abstract interface class EmailCheckSchemaCopyWith<T> {
  T call({String? email});
}

class _EmailCheckSchemaCopyWithImpl
    implements EmailCheckSchemaCopyWith<EmailCheckSchema> {
  const _EmailCheckSchemaCopyWithImpl(this._value);
  final EmailCheckSchema _value;

  @override
  EmailCheckSchema call({String? email}) =>
      EmailCheckSchema(email: email ?? _value.email);
}

class EmailCheckSchema {
  const EmailCheckSchema({this.email = ''});

  final String email;

  /// Creates a new [EmailCheckSchema] instance with auto-generated UUID if needed.
  factory EmailCheckSchema.create({String? email}) {
    return EmailCheckSchema(email: email ?? '');
  }

  EmailCheckSchemaCopyWith<EmailCheckSchema> get copyWith =>
      _EmailCheckSchemaCopyWithImpl(this);

  /// Converts this [EmailCheckSchema] to a Map representation.
  Map<String, Object?> toMap() => {'email': email};

  List<Object?> get _validationValues => [email];

  /// Validates this [EmailCheckSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _emailCheckSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [EmailCheckSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _emailCheckSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    EmailCheckSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [EmailCheckSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    EmailCheckSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [EmailCheckSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailCheckSchema && email == other.email;
  }

  @override
  int get hashCode => email.hashCode;
}

abstract final class EmailCheckFields {
  static StrictFieldRef<EmailCheckSchema, String> get email =>
      StrictFieldRef<EmailCheckSchema, String>.of(
        key: FieldKey.name('email'),
        get: (x) => x.email,
        set: (x, v) => x.copyWith(email: v),
      );
}
