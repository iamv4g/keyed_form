import 'dart:async';

import '../error.dart';
import '../issue.dart';
import 'validator.dart';

typedef EnumIssueRule<E extends Enum> =
    (KSIssue issue, KSError? ruleError)? Function(E? value);

typedef EnumRefinement<E extends Enum> = ({
  FutureOr<bool> Function(E? value) test,
  KSError? error,
  bool Function(E? value)? when,
  bool abort,
  Map<String, Object?>? params,
});

/// Enum validator for Keyed Schema.
class KSEnum<E extends Enum> extends KSValidator<E?> {
  KSEnum(
    this.values, {
    List<EnumIssueRule<E>>? rules,
    List<EnumRefinement<E>>? refinements,
    this.isOptional = false,
    this.isNullable = false,
    this.defaultValue,
    this.error,
  }) : _rules = rules ?? [],
       refinements = refinements ?? [];

  final List<E> values;
  final List<EnumIssueRule<E>> _rules;
  final List<EnumRefinement<E>> refinements;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final E? defaultValue;

  @override
  final KSError? error;

  KSEnum<E> copyWith({
    List<E>? values,
    List<EnumIssueRule<E>>? rules,
    List<EnumRefinement<E>>? refinements,
    bool? isOptional,
    bool? isNullable,
    E? defaultValue,
    KSError? error,
  }) {
    return KSEnum<E>(
      values ?? this.values,
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
    );
  }

  KSEnum<E> optional() => copyWith(isOptional: true);
  KSEnum<E> nullable() => copyWith(isNullable: true);
  KSEnum<E> defaultTo(E value) => copyWith(defaultValue: value);

  KSEnum<E> refine(
    FutureOr<bool> Function(E? value) test, {
    KSError? error,
    bool Function(E? value)? when,
    bool abort = false,
    Map<String, Object?>? params,
  }) {
    final next = List<EnumRefinement<E>>.from(refinements)
      ..add((
        test: test,
        error: error,
        when: when,
        abort: abort,
        params: params,
      ));
    return copyWith(refinements: next);
  }

  @override
  KSIssue? validateIssue(E? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: 'enum',
        input: null,
        message: 'Required',
      );
    }
    for (final rule in _rules) {
      final res = rule(val);
      if (res != null) return res.$1;
    }
    if (!values.contains(val)) {
      return KSInvalidValueIssue(
        values: values,
        input: val,
        message: 'Invalid selection',
      );
    }
    var isAborted = false;
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(val)) continue;
      final testResult = ref.test(val);
      if (testResult is Future) {
        throw const KSAsyncValidationError();
      }
      if (!testResult) {
        if (ref.abort) isAborted = true;
        return KSCustomIssue(
          input: val,
          params: ref.params,
          message: 'Invalid',
        );
      }
    }
    return null;
  }

  @override
  String? validate(E? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(expected: 'enum', input: null, message: 'Required'),
        validatorError: error,
      );
    }
    for (final rule in _rules) {
      final res = rule(val);
      if (res != null) {
        return resolveIssue(res.$1, ruleError: res.$2, validatorError: error);
      }
    }
    if (!values.contains(val)) {
      return resolveIssue(
        KSInvalidValueIssue(
          values: values,
          input: val,
          message: 'Invalid selection',
        ),
        validatorError: error,
      );
    }
    var isAborted = false;
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(val)) continue;
      final testResult = ref.test(val);
      if (testResult is Future) {
        throw const KSAsyncValidationError();
      }
      if (!testResult) {
        const defaultMsg = 'Invalid';
        final issue = KSCustomIssue(
          input: val,
          params: ref.params,
          message: defaultMsg,
        );
        final err =
            resolveIssue(issue, ruleError: ref.error, validatorError: error) ??
            defaultMsg;
        if (ref.abort) isAborted = true;
        return err;
      }
    }
    return null;
  }

  @override
  Future<KSIssue?> validateIssueAsync(E? value) async {
    final syncIssue = validateIssue(value);
    if (syncIssue != null) return syncIssue;

    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return null;
    }

    var isAborted = false;
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(val)) continue;
      final isValid = await ref.test(val);
      if (!isValid) {
        if (ref.abort) isAborted = true;
        return KSCustomIssue(
          input: val,
          params: ref.params,
          message: 'Invalid',
        );
      }
    }
    return null;
  }

  @override
  Future<String?> validateAsync(E? value) async {
    final syncError = validate(value);
    if (syncError != null) return syncError;

    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return null;
    }

    var isAborted = false;
    for (final ref in refinements) {
      if (isAborted) break;
      if (ref.when != null && !ref.when!(val)) continue;
      final isValid = await ref.test(val);
      if (!isValid) {
        const defaultMsg = 'Invalid';
        final issue = KSCustomIssue(
          input: val,
          params: ref.params,
          message: defaultMsg,
        );
        final err =
            resolveIssue(issue, ruleError: ref.error, validatorError: error) ??
            defaultMsg;
        if (ref.abort) isAborted = true;
        return err;
      }
    }
    return null;
  }
}
