import 'package:keyed_lens/keyed_lens.dart';

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

  final String discriminatorKey;
  final Map<String, KSObject> variants;
  final String? className;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final KSError? error;

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

  KSDiscriminatedUnion<T> optional() => copyWith(isOptional: true);
  KSDiscriminatedUnion<T> nullable() => copyWith(isNullable: true);

  /// Synchronously validates [data] against the matched variant schema.
  FieldErrors<String> validateMap(
    Map<String, Object?>? data, {
    FieldKey? prefix,
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
    return variantValidator.validateMap(data, prefix: prefix);
  }

  /// Asynchronously validates [data] against the matched variant schema.
  Future<FieldErrors<String>> validateMapAsync(
    Map<String, Object?>? data, {
    FieldKey? prefix,
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
    return variantValidator.validateMapAsync(data, prefix: prefix);
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
