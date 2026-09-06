import 'dart:async';

import '../error.dart';
import '../issue.dart';
import 'validator.dart';

typedef StringIssueRule =
    (KSIssue issue, KSError? ruleError)? Function(String? value);

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

  // Metadata for Code Generator AST inspection
  final int? minLength;
  final int? maxLength;
  final bool isEmail;
  final bool isNumeric;
  final bool isTime;
  final String? regexPattern;

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

  KSString optional() => copyWith(isOptional: true);

  KSString nullable() => copyWith(isNullable: true);

  KSString defaultTo(String value) => copyWith(defaultValue: value);

  KSString nonEmpty({KSError? error}) => min(1, error: error);

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
