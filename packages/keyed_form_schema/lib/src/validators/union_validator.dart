import 'package:keyed_form_core/keyed_form_core.dart';

import '../error.dart';
import '../issue.dart';
import 'object_validator.dart';
import 'validator.dart';

/// Discriminated union validator representing a polymorphic object schema.
class KSDiscriminatedUnion<T> extends KSValidator<Map<String, Object?>?> {
  KSDiscriminatedUnion(
    this.discriminatorKey,
    this.variants, {
    this.className,
    this.isOptional = false,
    this.isNullable = false,
    this.error,
  });

  /// The field whose value selects which variant schema applies.
  final String discriminatorKey;

  /// Variant schemas keyed by their discriminator value.
  final Map<String, KSObject> variants;

  /// Explicit name for the generated union base class, or `null` to derive it.
  final String? className;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final KSError? error;

  /// Returns a copy with the given fields replaced.
  KSDiscriminatedUnion<T> copyWith({
    String? discriminatorKey,
    Map<String, KSObject>? variants,
    String? className,
    bool? isOptional,
    bool? isNullable,
    KSError? error,
  }) {
    return KSDiscriminatedUnion<T>(
      discriminatorKey ?? this.discriminatorKey,
      variants ?? this.variants,
      className: className ?? this.className,
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      error: error ?? this.error,
    );
  }

  /// Allows the field to be omitted without failing.
  KSDiscriminatedUnion<T> optional() => copyWith(isOptional: true);

  /// Allows the field to be `null` without failing.
  KSDiscriminatedUnion<T> nullable() => copyWith(isNullable: true);

  /// Synchronously validates [data] against the matched variant schema.
  /// [scope] (an absolute key) narrows the walk to that subtree — see
  /// [KSObject.validateMap].
  FieldErrors<String> validateMap(
    Map<String, Object?>? data, {
    FieldKey? prefix,
    FieldKey? scope,
  }) {
    final rootPrefix = prefix ?? FieldKey.root;
    if (data == null) {
      if (isOptional || isNullable) return const FieldErrors.empty();
      final issue = const KSInvalidTypeIssue(
        expected: 'object',
        input: null,
        message: 'Required',
      );
      final msg = resolveIssue(issue, validatorError: error) ?? 'Required';
      return FieldErrors({rootPrefix: msg});
    }

    final discriminatorValue = data[discriminatorKey]?.toString();
    if (discriminatorValue == null ||
        !variants.containsKey(discriminatorValue)) {
      final targetKey = rootPrefix + .name(discriminatorKey);
      if (scope != null && !scope.contains(targetKey)) {
        return const FieldErrors.empty();
      }
      final issue = KSCustomIssue(
        path: [discriminatorKey],
        message: 'Invalid or missing discriminator "$discriminatorKey"',
      );
      final msg =
          resolveIssue(issue, validatorError: error) ??
          'Invalid or missing discriminator "$discriminatorKey"';
      return FieldErrors({targetKey: msg});
    }

    final variantValidator = variants[discriminatorValue]!;
    return variantValidator.validateMap(data, prefix: prefix, scope: scope);
  }

  /// Asynchronously validates [data] against the matched variant schema.
  Future<FieldErrors<String>> validateMapAsync(
    Map<String, Object?>? data, {
    FieldKey? prefix,
    FieldKey? scope,
  }) async {
    final rootPrefix = prefix ?? FieldKey.root;
    if (data == null) {
      if (isOptional || isNullable) return const FieldErrors.empty();
      final issue = const KSInvalidTypeIssue(
        expected: 'object',
        input: null,
        message: 'Required',
      );
      final msg = resolveIssue(issue, validatorError: error) ?? 'Required';
      return FieldErrors({rootPrefix: msg});
    }

    final discriminatorValue = data[discriminatorKey]?.toString();
    if (discriminatorValue == null ||
        !variants.containsKey(discriminatorValue)) {
      final targetKey = rootPrefix + .name(discriminatorKey);
      if (scope != null && !scope.contains(targetKey)) {
        return const FieldErrors.empty();
      }
      final issue = KSCustomIssue(
        path: [discriminatorKey],
        message: 'Invalid or missing discriminator "$discriminatorKey"',
      );
      final msg =
          resolveIssue(issue, validatorError: error) ??
          'Invalid or missing discriminator "$discriminatorKey"';
      return FieldErrors({targetKey: msg});
    }

    final variantValidator = variants[discriminatorValue]!;
    return variantValidator.validateMapAsync(
      data,
      prefix: prefix,
      scope: scope,
    );
  }

  @override
  KSIssue? validateIssue(Map<String, Object?>? value) {
    if (value == null) {
      if (isOptional || isNullable) return null;
      return const KSInvalidTypeIssue(
        expected: 'object',
        input: null,
        message: 'Required',
      );
    }
    final errors = validateMap(value);
    if (errors.isNotEmpty) {
      return const KSCustomIssue(message: 'Invalid union data');
    }
    return null;
  }

  @override
  String? validate(Map<String, Object?>? value) {
    final errors = validateMap(value);
    return errors.isEmpty ? null : 'Invalid union data';
  }
}
