// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_schema.dart';

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

abstract interface class LoginSchemaCopyWith<T> {
  T call({String? email, String? password, bool? remember});
}

class _LoginSchemaCopyWithImpl implements LoginSchemaCopyWith<LoginSchema> {
  const _LoginSchemaCopyWithImpl(this._value);
  final LoginSchema _value;

  @override
  LoginSchema call({String? email, String? password, bool? remember}) =>
      LoginSchema(
        email: email ?? _value.email,
        password: password ?? _value.password,
        remember: remember ?? _value.remember,
      );
}

class LoginSchema {
  const LoginSchema({
    this.email = '',
    this.password = '',
    this.remember = false,
  });

  final String email;
  final String password;
  final bool remember;

  /// Creates a new [LoginSchema] instance with auto-generated UUID if needed.
  factory LoginSchema.create({
    String? email,
    String? password,
    bool? remember,
  }) {
    return LoginSchema(
      email: email ?? '',
      password: password ?? '',
      remember: remember ?? false,
    );
  }

  LoginSchemaCopyWith<LoginSchema> get copyWith =>
      _LoginSchemaCopyWithImpl(this);

  /// Converts this [LoginSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'email': email,
    'password': password,
    'remember': remember,
  };

  List<Object?> get _validationValues => [email, password, remember];

  /// Validates this [LoginSchema] against its schema. Pass [scope] (a `FieldKey`)
  /// to re-check only that subtree — see `KeyedFormController.scopeOf`.
  FieldErrors<String> validate([FieldKey? scope]) =>
      _loginSchema.validateValues(_validationValues, scope: scope);

  /// Asynchronously validates this [LoginSchema] against its schema.
  Future<FieldErrors<String>> validateAsync([FieldKey? scope]) =>
      _loginSchema.validateValuesAsync(_validationValues, scope: scope);

  /// Static validator — assignable straight to `KeyedFormController.resolver`.
  static FieldErrors<String> validateData(
    LoginSchema schema, [
    FieldKey? scope,
  ]) => schema.validate(scope);

  /// Static async validator for [LoginSchema].
  static Future<FieldErrors<String>> validateDataAsync(
    LoginSchema schema, [
    FieldKey? scope,
  ]) => schema.validateAsync(scope);

  /// The default `KeyedFormController.scopeOf` for [LoginSchema] — a write inside a
  /// list row re-validates just that row, otherwise its top-level field.
  static FieldKey? scopeOf(FieldKey writtenKey) => rowScopeOf(writtenKey);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginSchema &&
        email == other.email &&
        password == other.password &&
        remember == other.remember;
  }

  @override
  int get hashCode => Object.hash(email, password, remember);
}

abstract final class LoginFields {
  static StrictFieldRef<LoginSchema, String> get email =>
      StrictFieldRef<LoginSchema, String>.of(
        key: FieldKey.name('email'),
        get: (x) => x.email,
        set: (x, v) => x.copyWith(email: v),
      );

  static StrictFieldRef<LoginSchema, String> get password =>
      StrictFieldRef<LoginSchema, String>.of(
        key: FieldKey.name('password'),
        get: (x) => x.password,
        set: (x, v) => x.copyWith(password: v),
      );

  static StrictFieldRef<LoginSchema, bool> get remember =>
      StrictFieldRef<LoginSchema, bool>.of(
        key: FieldKey.name('remember'),
        get: (x) => x.remember,
        set: (x, v) => x.copyWith(remember: v),
      );
}
