import 'dart:async';

import '../error.dart';
import '../issue.dart';
import 'validator.dart';

/// A single built-in string check: given the input, returns the [KSIssue] it
/// failed (with an optional per-rule [KSError] override), or `null` when it
/// passed. Rules are added by [KSString.min], [KSString.email] and friends.
typedef StringIssueRule =
    (KSIssue issue, KSError? ruleError)? Function(String? value);

/// A user-supplied predicate attached with [KSString.refine]: `test` receives
/// the value (optionally gated by `when`), `error` overrides the message,
/// `abort` stops later refinements on failure, and `params` is passed through
/// to the resulting [KSCustomIssue].
typedef StringRefinement = ({
  FutureOr<bool> Function(String? value) test,
  KSError? error,
  bool Function(String? value)? when,
  bool abort,
  Map<String, Object?>? params,
});

/// String validator for Keyed Schema.
class KSString extends KSValidator<String?> {
  KSString({
    List<StringIssueRule>? rules,
    List<StringRefinement>? refinements,
    this.isOptional = false,
    this.isNullable = false,
    this.defaultValue,
    this.error,
    this.minLength,
    this.maxLength,
    this.isEmail = false,
    this.isNumeric = false,
    this.isTime = false,
    this.regexPattern,
  }) : _rules = rules ?? [],
       refinements = refinements ?? [];

  final List<StringIssueRule> _rules;
  final List<StringRefinement> refinements;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final String? defaultValue;

  @override
  final KSError? error;

  // Metadata for Code Generator AST inspection — the generator reads these
  // back to reproduce constraints in generated models; runtime validation
  // uses the rule closures, not these fields.

  /// Minimum length set by [min] / [length], or `null`.
  final int? minLength;

  /// Maximum length set by [max] / [length], or `null`.
  final int? maxLength;

  /// Whether an [email] rule has been added.
  final bool isEmail;

  /// Whether a [numeric] rule has been added.
  final bool isNumeric;

  /// Whether a [time] rule has been added.
  final bool isTime;

  /// The pattern string of a [regex] rule, or `null`.
  final String? regexPattern;

  /// Returns a copy with the given fields replaced; every fluent method
  /// (`min`, `email`, `optional`, …) is built on top of this.
  KSString copyWith({
    List<StringIssueRule>? rules,
    List<StringRefinement>? refinements,
    bool? isOptional,
    bool? isNullable,
    String? defaultValue,
    KSError? error,
    int? minLength,
    int? maxLength,
    bool? isEmail,
    bool? isNumeric,
    bool? isTime,
    String? regexPattern,
  }) {
    return KSString(
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      isEmail: isEmail ?? this.isEmail,
      isNumeric: isNumeric ?? this.isNumeric,
      isTime: isTime ?? this.isTime,
      regexPattern: regexPattern ?? this.regexPattern,
    );
  }

  /// Allows the field to be omitted or empty without failing.
  KSString optional() => copyWith(isOptional: true);

  /// Allows the field to be `null` without failing.
  KSString nullable() => copyWith(isNullable: true);

  /// Substitutes [value] when the input is `null` before validating.
  KSString defaultTo(String value) => copyWith(defaultValue: value);

  /// Requires a non-empty string (equivalent to `min(1)`).
  KSString nonEmpty({KSError? error}) => min(1, error: error);

  /// Requires at least [length] characters. Empty input is left to the
  /// optional/nullable/required check, not flagged here.
  KSString min(int length, {KSError? error}) {
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (v.length < length) {
          return (
            KSTooSmallIssue(origin: .string, minimum: length, input: v),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, minLength: length);
  }

  /// Requires at most [length] characters.
  KSString max(int length, {KSError? error}) {
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (v.length > length) {
          return (
            KSTooBigIssue(origin: .string, maximum: length, input: v),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, maxLength: length);
  }

  /// Requires exactly [exactLength] characters.
  KSString length(int exactLength, {KSError? error}) {
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (v.length != exactLength) {
          return (
            KSTooSmallIssue(
              origin: .string,
              minimum: exactLength,
              exact: true,
              input: v,
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(
      rules: nextRules,
      minLength: exactLength,
      maxLength: exactLength,
    );
  }

  /// Requires the value to look like an email address.
  KSString email({KSError? error}) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (!emailRegex.hasMatch(v)) {
          return (
            KSInvalidFormatIssue(
              format: .email,
              input: v,
              message: 'Invalid email address',
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, isEmail: true);
  }

  /// Requires the value to match [regExp].
  KSString regex(RegExp regExp, {KSError? error}) {
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (!regExp.hasMatch(v)) {
          return (
            KSInvalidFormatIssue(
              format: .regex,
              pattern: regExp.pattern,
              input: v,
              message: 'Invalid format',
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, regexPattern: regExp.pattern);
  }

  /// Requires the value to be a decimal number in string form.
  KSString numeric({KSError? error}) {
    final numRegex = RegExp(r'^-?\d+(\.\d+)?$');
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (!numRegex.hasMatch(v)) {
          return (
            KSInvalidFormatIssue(
              format: .numeric,
              input: v,
              message: 'Must be a number',
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, isNumeric: true);
  }

  /// Requires an `HH:mm` 24-hour time string.
  KSString time({KSError? error}) {
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    final nextRules = List<StringIssueRule>.from(_rules)
      ..add((v) {
        if (v == null || v.isEmpty) return null;
        if (!timeRegex.hasMatch(v)) {
          return (
            KSInvalidFormatIssue(
              format: .time,
              input: v,
              message: 'Time format must be HH:mm',
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, isTime: true);
  }

  /// Adds a custom check [test] (sync or async). Fails with [error] when it
  /// returns `false`; [when] gates it, [abort] skips later refinements on
  /// failure, and [params] flows into the resulting [KSCustomIssue].
  KSString refine(
    FutureOr<bool> Function(String? value) test, {
    KSError? error,
    bool Function(String? value)? when,
    bool abort = false,
    Map<String, Object?>? params,
  }) {
    final next = List<StringRefinement>.from(refinements)
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
  KSIssue? validateIssue(String? value) {
    final val = value ?? defaultValue;
    if (val == null || val.trim().isEmpty) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: 'string',
        input: val,
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
  String? validate(String? value) {
    final val = value ?? defaultValue;
    if (val == null || val.trim().isEmpty) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(expected: 'string', input: val, message: 'Required'),
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
  Future<KSIssue?> validateIssueAsync(String? value) async {
    final val = value ?? defaultValue;
    if (val == null || val.trim().isEmpty) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: 'string',
        input: val,
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
  Future<String?> validateAsync(String? value) async {
    final val = value ?? defaultValue;
    if (val == null || val.trim().isEmpty) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(expected: 'string', input: val, message: 'Required'),
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
