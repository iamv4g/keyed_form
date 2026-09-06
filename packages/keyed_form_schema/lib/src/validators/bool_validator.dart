import 'dart:async';

import '../error.dart';
import '../issue.dart';
import 'validator.dart';

/// A single built-in boolean check: returns the [KSIssue] the value failed
/// (with an optional per-rule [KSError] override), or `null` when it passed.
typedef BoolIssueRule =
    (KSIssue issue, KSError? ruleError)? Function(bool? value);

/// A user-supplied predicate attached with [KSBool.refine]; see the fields'
/// roles under [KSBool.refine].
typedef BoolRefinement = ({
  FutureOr<bool> Function(bool? value) test,
  KSError? error,
  bool Function(bool? value)? when,
  bool abort,
  Map<String, Object?>? params,
});

/// Boolean validator for Keyed Schema.
class KSBool extends KSValidator<bool?> {
  KSBool({
    List<BoolIssueRule>? rules,
    List<BoolRefinement>? refinements,
    this.isOptional = false,
    this.isNullable = false,
    this.defaultValue,
    this.error,
    this.isTrueOnly = false,
  }) : _rules = rules ?? [],
       refinements = refinements ?? [];

  final List<BoolIssueRule> _rules;
  final List<BoolRefinement> refinements;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final bool? defaultValue;

  @override
  final KSError? error;

  /// Whether a [trueOnly] rule has been added (metadata for the generator).
  final bool isTrueOnly;

  /// Returns a copy with the given fields replaced.
  KSBool copyWith({
    List<BoolIssueRule>? rules,
    List<BoolRefinement>? refinements,
    bool? isOptional,
    bool? isNullable,
    bool? defaultValue,
    KSError? error,
    bool? isTrueOnly,
  }) {
    return KSBool(
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
      isTrueOnly: isTrueOnly ?? this.isTrueOnly,
    );
  }

  /// Requires the value to be `true` — for "must accept the terms" checkboxes.
  KSBool trueOnly({KSError? error}) {
    final nextRules = List<BoolIssueRule>.from(_rules)
      ..add(
        (v) => (v != true)
            ? (KSCustomIssue(input: v, message: 'Must be accepted'), error)
            : null,
      );
    return copyWith(rules: nextRules, isTrueOnly: true);
  }

  /// Allows the field to be omitted without failing.
  KSBool optional() => copyWith(isOptional: true);

  /// Allows the field to be `null` without failing.
  KSBool nullable() => copyWith(isNullable: true);

  /// Substitutes [value] when the input is `null` before validating.
  KSBool defaultTo(bool value) => copyWith(defaultValue: value);

  /// Adds a custom check [test] (sync or async), failing with [error] when it
  /// returns `false`. [when] gates it, [abort] skips later refinements on
  /// failure, and [params] flows into the resulting [KSCustomIssue].
  KSBool refine(
    FutureOr<bool> Function(bool? value) test, {
    KSError? error,
    bool Function(bool? value)? when,
    bool abort = false,
    Map<String, Object?>? params,
  }) {
    final next = List<BoolRefinement>.from(refinements)
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
  KSIssue? validateIssue(bool? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: 'bool',
        input: null,
        message: 'Required',
      );
    }
    for (final rule in _rules) {
      final res = rule(val);
      if (res != null) return res.$1;
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
  String? validate(bool? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(expected: 'bool', input: null, message: 'Required'),
        validatorError: error,
      );
    }
    for (final rule in _rules) {
      final res = rule(val);
      if (res != null) {
        return resolveIssue(res.$1, ruleError: res.$2, validatorError: error);
      }
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
  Future<KSIssue?> validateIssueAsync(bool? value) async {
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
  Future<String?> validateAsync(bool? value) async {
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
