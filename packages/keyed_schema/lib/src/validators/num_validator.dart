import 'dart:async';

import '../error.dart';
import '../issue.dart';
import 'validator.dart';

typedef NumIssueRule<T extends num> =
    (KSIssue issue, KSError? ruleError)? Function(T? value);

typedef NumRefinement<T extends num> = ({
  FutureOr<bool> Function(T? value) test,
  KSError? error,
  bool Function(T? value)? when,
  bool abort,
  Map<String, Object?>? params,
});

/// Base numeric validator.
abstract class _KSNumBase<T extends num, Self extends _KSNumBase<T, Self>>
    extends KSValidator<T?> {
  _KSNumBase({
    List<NumIssueRule<T>>? rules,
    List<NumRefinement<T>>? refinements,
    this.isOptional = false,
    this.isNullable = false,
    this.defaultValue,
    this.error,
    this.minVal,
    this.maxVal,
    this.isPositive = false,
    this.isNegative = false,
  }) : _rules = rules ?? [],
       refinements = refinements ?? [];

  final List<NumIssueRule<T>> _rules;
  final List<NumRefinement<T>> refinements;

  @override
  final bool isOptional;

  @override
  final bool isNullable;

  @override
  final T? defaultValue;

  @override
  final KSError? error;

  final num? minVal;
  final num? maxVal;
  final bool isPositive;
  final bool isNegative;

  KSIssueOrigin get origin;

  Self copyWith({
    List<NumIssueRule<T>>? rules,
    List<NumRefinement<T>>? refinements,
    bool? isOptional,
    bool? isNullable,
    T? defaultValue,
    KSError? error,
    num? minVal,
    num? maxVal,
    bool? isPositive,
    bool? isNegative,
  });

  Self optional() => copyWith(isOptional: true);

  Self nullable() => copyWith(isNullable: true);

  Self defaultTo(T value) => copyWith(defaultValue: value);

  Self min(num min, {KSError? error}) {
    final nextRules = List<NumIssueRule<T>>.from(_rules)
      ..add((v) {
        if (v == null) return null;
        if (v < min) {
          return (
            KSTooSmallIssue(origin: origin, minimum: min, input: v),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, minVal: min);
  }

  Self max(num max, {KSError? error}) {
    final nextRules = List<NumIssueRule<T>>.from(_rules)
      ..add((v) {
        if (v == null) return null;
        if (v > max) {
          return (KSTooBigIssue(origin: origin, maximum: max, input: v), error);
        }
        return null;
      });
    return copyWith(rules: nextRules, maxVal: max);
  }

  Self positive({KSError? error}) {
    final nextRules = List<NumIssueRule<T>>.from(_rules)
      ..add((v) {
        if (v == null) return null;
        if (v <= 0) {
          return (
            KSTooSmallIssue(
              origin: origin,
              minimum: 0,
              inclusive: false,
              input: v,
              message: 'Must be positive',
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, isPositive: true);
  }

  Self negative({KSError? error}) {
    final nextRules = List<NumIssueRule<T>>.from(_rules)
      ..add((v) {
        if (v == null) return null;
        if (v >= 0) {
          return (
            KSTooBigIssue(
              origin: origin,
              maximum: 0,
              inclusive: false,
              input: v,
              message: 'Must be negative',
            ),
            error,
          );
        }
        return null;
      });
    return copyWith(rules: nextRules, isNegative: true);
  }

  Self refine(
    FutureOr<bool> Function(T? value) test, {
    KSError? error,
    bool Function(T? value)? when,
    bool abort = false,
    Map<String, Object?>? params,
  }) {
    final next = List<NumRefinement<T>>.from(refinements)
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
  KSIssue? validateIssue(T? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: origin.name,
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
  String? validate(T? value) {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(
          expected: origin.name,
          input: null,
          message: 'Required',
        ),
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
  Future<KSIssue?> validateIssueAsync(T? value) async {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return KSInvalidTypeIssue(
        expected: origin.name,
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
  Future<String?> validateAsync(T? value) async {
    final val = value ?? defaultValue;
    if (val == null) {
      if (isOptional || isNullable) return null;
      return resolveIssue(
        KSInvalidTypeIssue(
          expected: origin.name,
          input: null,
          message: 'Required',
        ),
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

/// Integer validator for Keyed Schema.
class KSInt extends _KSNumBase<int, KSInt> {
  KSInt({
    super.rules,
    super.refinements,
    super.isOptional,
    super.isNullable,
    super.defaultValue,
    super.error,
    super.minVal,
    super.maxVal,
    super.isPositive,
    super.isNegative,
  });

  @override
  KSIssueOrigin get origin => KSIssueOrigin.int;

  @override
  KSInt copyWith({
    List<NumIssueRule<int>>? rules,
    List<NumRefinement<int>>? refinements,
    bool? isOptional,
    bool? isNullable,
    int? defaultValue,
    KSError? error,
    num? minVal,
    num? maxVal,
    bool? isPositive,
    bool? isNegative,
  }) {
    return KSInt(
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
      minVal: minVal ?? this.minVal,
      maxVal: maxVal ?? this.maxVal,
      isPositive: isPositive ?? this.isPositive,
      isNegative: isNegative ?? this.isNegative,
    );
  }
}

/// Double validator for Keyed Schema.
class KSDouble extends _KSNumBase<double, KSDouble> {
  KSDouble({
    super.rules,
    super.refinements,
    super.isOptional,
    super.isNullable,
    super.defaultValue,
    super.error,
    super.minVal,
    super.maxVal,
    super.isPositive,
    super.isNegative,
  });

  @override
  KSIssueOrigin get origin => KSIssueOrigin.double;

  @override
  KSDouble copyWith({
    List<NumIssueRule<double>>? rules,
    List<NumRefinement<double>>? refinements,
    bool? isOptional,
    bool? isNullable,
    double? defaultValue,
    KSError? error,
    num? minVal,
    num? maxVal,
    bool? isPositive,
    bool? isNegative,
  }) {
    return KSDouble(
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
      minVal: minVal ?? this.minVal,
      maxVal: maxVal ?? this.maxVal,
      isPositive: isPositive ?? this.isPositive,
      isNegative: isNegative ?? this.isNegative,
    );
  }
}

/// General number validator for Keyed Schema.
class KSNum extends _KSNumBase<num, KSNum> {
  KSNum({
    super.rules,
    super.refinements,
    super.isOptional,
    super.isNullable,
    super.defaultValue,
    super.error,
    super.minVal,
    super.maxVal,
    super.isPositive,
    super.isNegative,
  });

  @override
  KSIssueOrigin get origin => KSIssueOrigin.number;

  @override
  KSNum copyWith({
    List<NumIssueRule<num>>? rules,
    List<NumRefinement<num>>? refinements,
    bool? isOptional,
    bool? isNullable,
    num? defaultValue,
    KSError? error,
    num? minVal,
    num? maxVal,
    bool? isPositive,
    bool? isNegative,
  }) {
    return KSNum(
      rules: rules ?? List.from(_rules),
      refinements: refinements ?? List.from(this.refinements),
      isOptional: isOptional ?? this.isOptional,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      error: error ?? this.error,
      minVal: minVal ?? this.minVal,
      maxVal: maxVal ?? this.maxVal,
      isPositive: isPositive ?? this.isPositive,
      isNegative: isNegative ?? this.isNegative,
    );
  }
}
