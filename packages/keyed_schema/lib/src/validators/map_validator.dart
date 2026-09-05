import '../error.dart';
import '../issue.dart';
import 'validator.dart';

/// Validator for Map fields, optionally validating key and value constraints.
class KSMap<K, V> extends KSValidator<Map<K, V>?> {
  const KSMap({
    this.keyValidator,
    this.valueValidator,
    this.isOptional = false,
    this.isNullable = false,
    this.defaultValue,
    this.error,
  });

  /// Optional validator applied to every key in the Map.
  final KSValidator<K>? keyValidator;

  /// Optional validator applied to every value in the Map.
  final KSValidator<V>? valueValidator;

  @override
  final KSError? error;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final Map<K, V>? defaultValue;

  KSMap<K, V> optional() => KSMap<K, V>(
    keyValidator: keyValidator,
    valueValidator: valueValidator,
    isOptional: true,
    isNullable: isNullable,
    defaultValue: defaultValue,
    error: error,
  );

  KSMap<K, V> nullable() => KSMap<K, V>(
    keyValidator: keyValidator,
    valueValidator: valueValidator,
    isOptional: isOptional,
    isNullable: true,
    defaultValue: defaultValue,
    error: error,
  );

  KSMap<K, V> defaultTo(Map<K, V> value) => KSMap<K, V>(
    keyValidator: keyValidator,
    valueValidator: valueValidator,
    isOptional: isOptional,
    isNullable: isNullable,
    defaultValue: value,
    error: error,
  );

  @override
  KSIssue? validateIssue(Map<K, V>? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: 'map',
        input: null,
        message: 'Required',
      );
    }

    if (keyValidator != null || valueValidator != null) {
      for (final entry in val.entries) {
        if (keyValidator != null) {
          final issue = keyValidator!.validateIssue(entry.key);
          if (issue != null) {
            return issue;
          }
        }
        if (valueValidator != null) {
          final issue = valueValidator!.validateIssue(entry.value);
          if (issue != null) {
            return issue;
          }
        }
      }
    }
    return null;
  }

  @override
  String? validate(Map<K, V>? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(
          expected: 'map',
          input: null,
          message: 'Required',
        ),
        validatorError: error,
      );
    }

    if (keyValidator != null || valueValidator != null) {
      for (final entry in val.entries) {
        if (keyValidator != null) {
          final err = keyValidator!.validate(entry.key);
          if (err != null) return err;
        }
        if (valueValidator != null) {
          final err = valueValidator!.validate(entry.value);
          if (err != null) return err;
        }
      }
    }
    return null;
  }
}
