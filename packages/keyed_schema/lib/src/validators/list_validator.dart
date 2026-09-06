import 'dart:async';

import '../error.dart';
import '../issue.dart';
import 'validator.dart';

/// A single built-in list check: returns the [KSIssue] the list failed (with
/// an optional per-rule [KSError] override), or `null` when it passed.
typedef ListIssueRule<E> =
    (KSIssue issue, KSError? ruleError)? Function(List<E>? value);

/// A user-supplied predicate attached with [KSList.refine]; see [KSList.refine]
/// for the field roles.
typedef ListRefinement<E> = ({
  FutureOr<bool> Function(List<E>? value) test,
  KSError? error,
  bool Function(List<E>? value)? when,
  bool abort,
  Map<String, Object?>? params,
});

/// List validator for Keyed Schema.
class KSList<E> extends KSValidator<List<E>?> {
  KSList(
    this.elementValidator, {
    List<ListIssueRule<E>>? rules,
    List<ListRefinement<E>>? refinements,
    this.isOptional = false,
    this.isNullable = false,
    this.defaultValue,
    this.error,
    this.minItems,
    this.maxItems,
    this.isNonEmpty = false,
  }) : _rules = rules ?? [],
       refinements = refinements ?? [];

  /// Applied to every element of the list.
  final KSValidator<E> elementValidator;
  final List<ListIssueRule<E>> _rules;
  final List<ListRefinement<E>> refinements;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final List<E>? defaultValue;

  @override
  final KSError? error;

  /// Minimum length set by [min], or `null` (metadata for the generator).
  final int? minItems;

  /// Maximum length set by [max], or `null`.
  final int? maxItems;

  /// Whether a [nonEmpty] rule has been added.
  final bool isNonEmpty;

  /// Returns a copy with the given fields replaced.
  KSList<E> copyWith({
    KSValidator<E>? elementValidator,
    List<ListIssueRule<E>>? rules,
    List<ListRefinement<E>>? refinements,
    bool? isOptional,
    bool? isNullable,
    List<E>? defaultValue,
    KSError? error,
    int? minItems,
    int? maxItems,
    bool? isNonEmpty,
  }) {
    return KSList<E>(
      elementValidator ?? this.elementValidator,
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
      minItems: minItems ?? this.minItems,
      maxItems: maxItems ?? this.maxItems,
      isNonEmpty: isNonEmpty ?? this.isNonEmpty,
    );
  }

  /// Allows the field to be omitted without failing.
  KSList<E> optional() => copyWith(isOptional: true);

  /// Allows the field to be `null` without failing.
  KSList<E> nullable() => copyWith(isNullable: true);

  /// Substitutes [value] when the input is `null` before validating.
  KSList<E> defaultTo(List<E> value) => copyWith(defaultValue: value);

  /// Requires at least one element (equivalent to `min(1)`).
  KSList<E> nonEmpty({KSError? error}) => min(1, error: error);

  /// Requires at least [count] elements.
  KSList<E> min(int count, {KSError? error}) {
    final nextRules = List<ListIssueRule<E>>.from(_rules)
      ..add((v) {
        if (v == null) return null;
        if (v.length < count) {
          return (
            KSTooSmallIssue(origin: .list, minimum: count, input: v),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, minItems: count);
  }

  /// Requires at most [count] elements.
  KSList<E> max(int count, {KSError? error}) {
    final nextRules = List<ListIssueRule<E>>.from(_rules)
      ..add((v) {
        if (v == null) return null;
        if (v.length > count) {
          return (
            KSTooBigIssue(origin: .list, maximum: count, input: v),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, maxItems: count);
  }

  /// Adds a custom check [test] (sync or async) over the whole list, failing
  /// with [error] when it returns `false`. [when] gates it, [abort] skips
  /// later refinements on failure, and [params] flows into the [KSCustomIssue].
  KSList<E> refine(
    FutureOr<bool> Function(List<E>? value) test, {
    KSError? error,
    bool Function(List<E>? value)? when,
    bool abort = false,
    Map<String, Object?>? params,
  }) {
    final next = List<ListRefinement<E>>.from(refinements)
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
  KSIssue? validateIssue(List<E>? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: 'list',
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
  String? validate(List<E>? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(expected: 'list', input: null, message: 'Required'),
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
  Future<KSIssue?> validateIssueAsync(List<E>? value) async {
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
  Future<String?> validateAsync(List<E>? value) async {
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
