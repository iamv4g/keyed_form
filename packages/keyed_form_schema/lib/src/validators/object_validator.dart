import 'dart:async';

import 'package:keyed_form_core/keyed_form_core.dart';

import '../error.dart';
import '../issue.dart';
import 'list_validator.dart';
import 'union_validator.dart';
import 'validator.dart';

/// A cross-field check attached with [KSObject.refine]: `test` receives the
/// whole data map, `path` / `key` place the resulting error on a field
/// (defaulting to the object root), `when` gates it, `abort` stops later
/// refinements, and `params` flows into the [KSCustomIssue].
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

  /// Explicit name for the generated data class, or `null` to derive it from
  /// the schema variable / field name.
  final String? className;

  /// The field validators, keyed by field name.
  final Map<String, KSValidator<Object?>> fields;

  /// Cross-field checks added with [refine], run after per-field validation.
  final List<ObjectRefinement> refinements;

  /// [fields] as a fixed list, so validation does not re-materialise the
  /// `entries` iterable on every call. A [KSObject] is built once (via
  /// `ks.object(...)`) and reused for every keystroke.
  late final List<MapEntry<String, KSValidator<Object?>>> _fieldList =
      fields.entries.toList(growable: false);

  /// The per-field [FieldKey]s relative to this object's root, computed once.
  /// A `FieldKey` is immutable; without this the same N keys are rebuilt on
  /// every validation.
  late final Map<String, FieldKey> _fieldKeys = {
    for (final name in fields.keys) name: FieldKey.name(name),
  };

  /// [rootPrefix] + the cached key for [fieldName], skipping the concat for
  /// the common top-level (root prefix) case.
  FieldKey _fieldKey(FieldKey rootPrefix, String fieldName) =>
      rootPrefix.isRoot
          ? _fieldKeys[fieldName]!
          : rootPrefix + _fieldKeys[fieldName]!;

  /// Zips positional [orderedValues] back to a `{name: value}` map — only for
  /// the refinement callbacks, which want the whole object.
  Map<String, Object?> _orderedMap(List<Object?> orderedValues) {
    final out = <String, Object?>{};
    for (var i = 0; i < _fieldList.length; i++) {
      out[_fieldList[i].key] = orderedValues[i];
    }
    return out;
  }

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final KSError? error;

  /// Returns a copy with the given fields replaced.
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

  /// Allows the whole object to be omitted without failing.
  KSObject optional() => copyWith(isOptional: true);

  /// Allows the whole object to be `null` without failing.
  KSObject nullable() => copyWith(isNullable: true);

  /// Adds a cross-field check [test] (sync or async) over the whole data map.
  /// See [ObjectRefinement] for the parameter roles.
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

  /// Validates a present object whose field values are supplied positionally,
  /// **in this object's declared field order** ([fields] iteration order) —
  /// for the generated `validate()`, which passes a list literal instead of
  /// building a `Map` (no per-key hashing, O(1) access). Nested objects /
  /// lists must already be mapped by the caller (as `toMap()` would).
  /// Refinements still receive a map, rebuilt lazily only if one runs.
  FieldErrors<String> validateReader(
    List<Object?> orderedValues, {
    FieldKey? prefix,
  }) {
    assert(
      orderedValues.length == _fieldList.length,
      'validateReader expects ${_fieldList.length} values in field order, '
      'got ${orderedValues.length}',
    );
    return validateMap(null, prefix: prefix, orderedValues: orderedValues);
  }

  /// Synchronously validates [data] and returns [FieldErrors] keyed by [FieldKey].
  ///
  /// When [orderedValues] is given, fields are read from it positionally and
  /// [data] is only the (optional) refinement map — see [validateReader].
  FieldErrors<String> validateMap(
    Map<String, Object?>? data, {
    FieldKey? prefix,
    List<Object?>? orderedValues,
  }) {
    final rootPrefix = prefix ?? FieldKey.root;
    if (data == null && orderedValues == null) {
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
    for (var i = 0; i < _fieldList.length; i++) {
      final entry = _fieldList[i];
      final fieldName = entry.key;
      final validator = entry.value;
      final fieldValue =
          orderedValues != null ? orderedValues[i] : data![fieldName];
      final fieldKey = _fieldKey(rootPrefix, fieldName);

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

    // 2. Run object refinements — they take the whole map, so materialise one
    // (from [orderedValues]) only if there is a refinement to run.
    var isAborted = false;
    final refineData = refinements.isEmpty
        ? const <String, Object?>{}
        : (data ?? _orderedMap(orderedValues!));
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(refineData)) continue;

      final testResult = ref.test(refineData);
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

  /// [validateReader] for [validateMapAsync].
  Future<FieldErrors<String>> validateReaderAsync(
    List<Object?> orderedValues, {
    FieldKey? prefix,
  }) {
    assert(orderedValues.length == _fieldList.length);
    return validateMapAsync(null, prefix: prefix, orderedValues: orderedValues);
  }

  /// Asynchronously validates [data] and returns [FieldErrors] keyed by [FieldKey].
  Future<FieldErrors<String>> validateMapAsync(
    Map<String, Object?>? data, {
    FieldKey? prefix,
    List<Object?>? orderedValues,
  }) async {
    final rootPrefix = prefix ?? FieldKey.root;
    if (data == null && orderedValues == null) {
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
    for (var i = 0; i < _fieldList.length; i++) {
      final entry = _fieldList[i];
      final fieldName = entry.key;
      final validator = entry.value;
      final fieldValue =
          orderedValues != null ? orderedValues[i] : data![fieldName];
      final fieldKey = _fieldKey(rootPrefix, fieldName);

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

    // 2. Run object refinements — materialise a map from [orderedValues] only
    // if a refinement will use it.
    var isAborted = false;
    final refineData = refinements.isEmpty
        ? const <String, Object?>{}
        : (data ?? _orderedMap(orderedValues!));
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(refineData)) continue;

      final isValid = await ref.test(refineData);
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
