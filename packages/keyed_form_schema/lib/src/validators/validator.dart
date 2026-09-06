import '../error.dart';
import '../issue.dart';

/// Base class for all KS validators.
abstract class KSValidator<T> {
  const KSValidator();

  /// Synchronously validates [value]. Returns an error message if invalid, or null if valid.
  String? validate(T value) {
    final issue = validateIssue(value);
    return resolveIssue(issue, validatorError: error);
  }

  /// Synchronously validates [value] returning a [KSIssue] if invalid, or null if valid.
  KSIssue? validateIssue(T value);

  /// Asynchronously validates [value]. Defaults to calling [validate].
  Future<String?> validateAsync(T value) async => validate(value);

  /// Asynchronously validates [value] returning a [KSIssue] if invalid, or null if valid.
  Future<KSIssue?> validateIssueAsync(T value) async => validateIssue(value);

  /// Whether this field is optional (can be omitted / empty).
  bool get isOptional => false;

  /// Whether this field allows null.
  bool get isNullable => false;

  /// Optional default value if none provided.
  T? get defaultValue => null;

  /// Configured error resolver on this validator (e.g. from factory constructor).
  KSError? get error => null;
}

/// Resolves an issue to an error string following the precedence:
/// 1. [ruleError] (if defined and resolves to non-null)
/// 2. [validatorError] (if defined and resolves to non-null)
/// 3. `issue.message` (default fallback)
String? resolveIssue(
  KSIssue? issue, {
  KSError? ruleError,
  KSError? validatorError,
}) {
  if (issue == null) return null;
  if (ruleError != null) {
    final custom = ruleError.resolve(issue);
    if (custom != null) return custom;
  }
  if (validatorError != null) {
    final custom = validatorError.resolve(issue);
    if (custom != null) return custom;
  }
  return issue.message;
}

/// Resolves a message that can be either a [String], a lazy callback `String Function()`, or a [KSError].
String resolveKSMessage(Object? message, [String fallback = 'Invalid']) {
  return switch (message) {
    String value => value,
    String Function() callback => callback(),
    KSError err => err.resolve(KSCustomIssue(message: fallback)) ?? fallback,
    _ => fallback,
  };
}
