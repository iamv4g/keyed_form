import 'error.dart';
import 'validators/bool_validator.dart';
import 'validators/enum_validator.dart';
import 'validators/list_validator.dart';
import 'validators/map_validator.dart';
import 'validators/num_validator.dart';
import 'validators/object_validator.dart';
import 'validators/string_validator.dart';
import 'validators/union_validator.dart';
import 'validators/validator.dart';

/// The global entrypoint for creating Keyed Schemas.
const ks = _KSNamespace();

class _KSNamespace {
  const _KSNamespace();

  /// Creates an object schema representing a structured model.
  KSObject object(
    Map<String, KSValidator<Object?>> fields, {
    String? className,
    KSError? error,
  }) => KSObject(fields, className: className, error: error);

  /// Creates a string validator.
  KSString string({KSError? error}) => KSString(error: error);

  /// Creates an integer validator.
  KSInt int({KSError? error}) => KSInt(error: error);

  /// Creates a double validator.
  KSDouble double({KSError? error}) => KSDouble(error: error);

  /// Creates a general number validator.
  KSNum number({KSError? error}) => KSNum(error: error);

  /// Creates a general number validator (alias for number).
  KSNum num({KSError? error}) => KSNum(error: error);

  /// Creates a boolean validator.
  KSBool boolean({KSError? error}) => KSBool(error: error);

  /// Creates an enum validator against the provided enum [values].
  KSEnum<E> enums<E extends Enum>(List<E> values, {KSError? error}) =>
      KSEnum<E>(values, error: error);

  /// Creates a list validator validating each element with [itemValidator].
  KSList<E> list<E>(KSValidator<E> itemValidator, {KSError? error}) =>
      KSList<E>(itemValidator, error: error);

  /// Creates a map validator validating every key with [keyValidator] and every value with [valueValidator].
  KSMap<K, V> map<K, V>(
    KSValidator<K> keyValidator,
    KSValidator<V> valueValidator, {
    KSError? error,
  }) => KSMap<K, V>(
    keyValidator: keyValidator,
    valueValidator: valueValidator,
    error: error,
  );

  /// Creates a discriminated union validator for polymorphic object schemas.
  KSDiscriminatedUnion<T> discriminatedUnion<T>(
    String discriminator,
    Map<String, KSObject> variants, {
    String? className,
    KSError? error,
  }) => KSDiscriminatedUnion<T>(
    discriminator,
    variants,
    className: className,
    error: error,
  );
}
