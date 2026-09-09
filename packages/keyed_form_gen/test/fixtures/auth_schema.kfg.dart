// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_schema.dart';

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

abstract interface class AuthSchemaCopyWith<T> {
  T call({String? username, String? password, bool? remember});
}

class _AuthSchemaCopyWithImpl implements AuthSchemaCopyWith<AuthSchema> {
  const _AuthSchemaCopyWithImpl(this._value);
  final AuthSchema _value;

  @override
  AuthSchema call({String? username, String? password, bool? remember}) =>
      AuthSchema(
        username: username ?? _value.username,
        password: password ?? _value.password,
        remember: remember ?? _value.remember,
      );
}

class AuthSchema {
  const AuthSchema({
    this.username = '',
    this.password = '',
    this.remember = false,
  });

  final String username;
  final String password;
  final bool remember;

  /// Creates a new [AuthSchema] instance with auto-generated UUID if needed.
  factory AuthSchema.create({
    String? username,
    String? password,
    bool? remember,
  }) {
    return AuthSchema(
      username: username ?? '',
      password: password ?? '',
      remember: remember ?? false,
    );
  }

  AuthSchemaCopyWith<AuthSchema> get copyWith => _AuthSchemaCopyWithImpl(this);

  /// Converts this [AuthSchema] to a Map representation.
  Map<String, Object?> toMap() => {
    'username': username,
    'password': password,
    'remember': remember,
  };

  List<Object?> get _validationValues => [username, password, remember];

  /// Synchronously validates this [AuthSchema] against its schema.
  FieldErrors<String> validate() =>
      authSchema.validateReader(_validationValues);

  /// Asynchronously validates this [AuthSchema] against its schema.
  Future<FieldErrors<String>> validateAsync() =>
      authSchema.validateReaderAsync(_validationValues);

  /// Static validator function for [AuthSchema], suitable for Riverpod or callbacks.
  static FieldErrors<String> validateData(AuthSchema schema) =>
      schema.validate();

  /// Static async validator function for [AuthSchema].
  static Future<FieldErrors<String>> validateDataAsync(AuthSchema schema) =>
      schema.validateAsync();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthSchema &&
        username == other.username &&
        password == other.password &&
        remember == other.remember;
  }

  @override
  int get hashCode => Object.hash(username, password, remember);
}

abstract final class AuthFields {
  static StrictFieldRef<AuthSchema, String> get username =>
      StrictFieldRef<AuthSchema, String>.of(
        key: FieldKey.name('username'),
        get: (x) => x.username,
        set: (x, v) => x.copyWith(username: v),
      );

  static StrictFieldRef<AuthSchema, String> get password =>
      StrictFieldRef<AuthSchema, String>.of(
        key: FieldKey.name('password'),
        get: (x) => x.password,
        set: (x, v) => x.copyWith(password: v),
      );

  static StrictFieldRef<AuthSchema, bool> get remember =>
      StrictFieldRef<AuthSchema, bool>.of(
        key: FieldKey.name('remember'),
        get: (x) => x.remember,
        set: (x, v) => x.copyWith(remember: v),
      );
}
