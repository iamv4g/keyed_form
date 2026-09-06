import 'dart:async';

import 'package:keyed_lens/keyed_lens.dart';

import '../error.dart';
import '../issue.dart';
import 'list_validator.dart';
import 'union_validator.dart';
import 'validator.dart';

typedef ObjectRefinement = ({
  FutureOr<bool> Function(Map<String, Object?> data) test,
  KSError? error,
  String? path,
  FieldKey? key,
  bool Function(Map<String, Object?> data)? when,
  bool abort,
  Map<String, Object?>? params,
});

/// Object validator representing a structured form schema.
class KSObject extends KSValidator<Map<String, Object?>?> {
  KSObject(
    this.fields, {
    this.className,
    List<ObjectRefinement>? refinements,
    this.isOptional = false,
    this.isNullable = false,
    this.error,
  }) : refinements = refinements ?? [];

  final String? className;
  final Map<String, KSValidator<Object?>> fields;
  final List<ObjectRefinement> refinements;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final KSError? error;

  KSObject copyWith({
    String? className,
    Map<String, KSValidator<Object?>>? fields,
    List<ObjectRefinement>? refinements,
    bool? isOptional,
    bool? isNullable,
    KSError? error,
  }) {
    return KSObject(
      fields ?? this.fields,
      className: className ?? this.className,
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      error: error ?? this.error,
    );
  }

  KSObject optional() => copyWith(isOptional: true);
  KSObject nullable() => copyWith(isNullable: true);

  KSObject refine(
    FutureOr<bool> Function(Map<String, Object?> data) test, {
    KSError? error,
    String? path,
    FieldKey? key,
    bool Function(Map<String, Object?> data)? when,
    bool abort = false,
    Map<String, Object?>? params,
  }) {
    final next = List<ObjectRefinement>.from(refinements)
      ..add((
        test: test,
        error: error,
        path: path,
        key: key,
        when: when,
        abort: abort,
        params: params,
      ));
    return copyWith(refinements: next);
  }

  /// Synchronously validates [data] and returns [FieldErrors] keyed by [FieldKey].
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

    final errors = <FieldKey, String>{};

    // 1. Validate each field
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final fieldValue = data[fieldName];
      final fieldKey = rootPrefix + .name(fieldName);

      if (validator is KSObject) {
        final nestedErrors = validator.validateMap(
          fieldValue is Map<String, Object?>
              ? fieldValue
              : (fieldValue is Map
                    ? Map<String, Object?>.from(fieldValue)
                    : null),
          prefix: fieldKey,
        );
        for (final k in nestedErrors.keys) {
          final err = nestedErrors.byKey(k);
          if (err != null) errors[k] = err;
        }
      } else if (validator is KSDiscriminatedUnion) {
        final nestedErrors = validator.validateMap(
          fieldValue is Map<String, Object?>
              ? fieldValue
              : (fieldValue is Map
                    ? Map<String, Object?>.from(fieldValue)
                    : null),
          prefix: fieldKey,
        );
        for (final k in nestedErrors.keys) {
          final err = nestedErrors.byKey(k);
          if (err != null) errors[k] = err;
        }
      } else if (validator is KSList) {
        final listError = validator.validate(
          fieldValue is List ? fieldValue : null,
        );
        if (listError != null) {
          errors[fieldKey] = listError;
        }
        if (fieldValue is List) {
          final elemValidator = validator.elementValidator;
          if (elemValidator is KSObject) {
            for (var i = 0; i < fieldValue.length; i++) {
              final item = fieldValue[i];
              if (item is Map) {
                final typedItem = item is Map<String, Object?>
                    ? item
                    : Map<String, Object?>.from(item);
                final idVal = typedItem['clientId'] ?? typedItem['id'] ?? i;
                final itemKey = fieldKey + .id(idVal);
                final itemErrors = elemValidator.validateMap(
                  typedItem,
                  prefix: itemKey,
                );
                for (final k in itemErrors.keys) {
                  final err = itemErrors.byKey(k);
                  if (err != null) errors[k] = err;
                }
              }
            }
          } else if (elemValidator is KSDiscriminatedUnion) {
            for (var i = 0; i < fieldValue.length; i++) {
              final item = fieldValue[i];
              if (item is Map) {
                final typedItem = item is Map<String, Object?>
                    ? item
                    : Map<String, Object?>.from(item);
                final idVal = typedItem['clientId'] ?? typedItem['id'] ?? i;
                final itemKey = fieldKey + .id(idVal);
                final itemErrors = elemValidator.validateMap(
                  typedItem,
                  prefix: itemKey,
                );
                for (final k in itemErrors.keys) {
                  final err = itemErrors.byKey(k);
                  if (err != null) errors[k] = err;
                }
              }
            }
          }
        }
      } else {
        final error = validator.validate(fieldValue);
        if (error != null) {
          errors[fieldKey] = error;
        }
      }
    }

    // 2. Run object refinements
    var isAborted = false;
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(data)) continue;

      final testResult = ref.test(data);
      if (testResult is Future) {
        throw const KSAsyncValidationError();
      }

      if (!testResult) {
        final targetKey = ref.key != null
            ? rootPrefix + ref.key!
            : (ref.path != null ? rootPrefix + .name(ref.path!) : rootPrefix);
        const defaultMsg = 'Invalid';
        final issue = KSCustomIssue(
          path: ref.path != null ? [ref.path!] : const [],
          params: ref.params,
          message: defaultMsg,
        );
        errors[targetKey] =
            resolveIssue(issue, ruleError: ref.error) ?? defaultMsg;
        if (ref.abort) {
          isAborted = true;
        }
      }
    }

    return FieldErrors(errors);
  }

  /// Asynchronously validates [data] and returns [FieldErrors] keyed by [FieldKey].
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

    final errors = <FieldKey, String>{};

    // 1. Validate each field
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final fieldValue = data[fieldName];
      final fieldKey = rootPrefix + .name(fieldName);

      if (validator is KSObject) {
        final nestedErrors = await validator.validateMapAsync(
          fieldValue is Map<String, Object?>
              ? fieldValue
              : (fieldValue is Map
                    ? Map<String, Object?>.from(fieldValue)
                    : null),
          prefix: fieldKey,
        );
        for (final k in nestedErrors.keys) {
          final err = nestedErrors.byKey(k);
          if (err != null) errors[k] = err;
        }
      } else if (validator is KSDiscriminatedUnion) {
        final nestedErrors = validator.validateMap(
          fieldValue is Map<String, Object?>
              ? fieldValue
              : (fieldValue is Map
                    ? Map<String, Object?>.from(fieldValue)
                    : null),
          prefix: fieldKey,
        );
        for (final k in nestedErrors.keys) {
          final err = nestedErrors.byKey(k);
          if (err != null) errors[k] = err;
        }
      } else if (validator is KSList) {
        final listError = await validator.validateAsync(
          fieldValue is List ? fieldValue : null,
        );
        if (listError != null) {
          errors[fieldKey] = listError;
        }
        if (fieldValue is List) {
          final elemValidator = validator.elementValidator;
          if (elemValidator is KSObject) {
            for (var i = 0; i < fieldValue.length; i++) {
              final item = fieldValue[i];
              if (item is Map) {
                final typedItem = item is Map<String, Object?>
                    ? item
                    : Map<String, Object?>.from(item);
                final idVal = typedItem['clientId'] ?? typedItem['id'] ?? i;
                final itemKey = fieldKey + .id(idVal);
                final itemErrors = await elemValidator.validateMapAsync(
                  typedItem,
                  prefix: itemKey,
                );
                for (final k in itemErrors.keys) {
                  final err = itemErrors.byKey(k);
                  if (err != null) errors[k] = err;
                }
              }
            }
          } else if (elemValidator is KSDiscriminatedUnion) {
            for (var i = 0; i < fieldValue.length; i++) {
              final item = fieldValue[i];
              if (item is Map) {
                final typedItem = item is Map<String, Object?>
                    ? item
                    : Map<String, Object?>.from(item);
                final idVal = typedItem['clientId'] ?? typedItem['id'] ?? i;
                final itemKey = fieldKey + .id(idVal);
                final itemErrors = elemValidator.validateMap(
                  typedItem,
                  prefix: itemKey,
                );
                for (final k in itemErrors.keys) {
                  final err = itemErrors.byKey(k);
                  if (err != null) errors[k] = err;
                }
              }
            }
          }
        }
      } else {
        final error = await validator.validateAsync(fieldValue);
        if (error != null) {
          errors[fieldKey] = error;
        }
      }
    }

    // 2. Run object refinements
    var isAborted = false;
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(data)) continue;

      final isValid = await ref.test(data);
      if (!isValid) {
        final targetKey = ref.key != null
            ? rootPrefix + ref.key!
            : (ref.path != null ? rootPrefix + .name(ref.path!) : rootPrefix);
        const defaultMsg = 'Invalid';
        final issue = KSCustomIssue(
          path: ref.path != null ? [ref.path!] : const [],
          params: ref.params,
          message: defaultMsg,
        );
        errors[targetKey] =
            resolveIssue(issue, ruleError: ref.error) ?? defaultMsg;
        if (ref.abort) {
          isAborted = true;
        }
      }
    }

    return FieldErrors(errors);
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
      return const KSCustomIssue(message: 'Invalid data');
    }
    return null;
  }

  @override
  String? validate(Map<String, Object?>? value) {
    final errors = validateMap(value);
    return errors.isEmpty ? null : 'Invalid data';
  }

  @override
  Future<String?> validateAsync(Map<String, Object?>? value) async {
    final errors = await validateMapAsync(value);
    return errors.isEmpty ? null : 'Invalid data';
  }
}
