import 'issue.dart';

/// Sealed class representing how an issue should be formatted or resolved into an error message.
sealed class KSError {
  /// Constant string error message (non-const to avoid prefer_const_constructors lint).
  factory KSError.text(String text) = _KSErrorText;

  /// Dynamic error builder callback supporting both i18n and [KSIssue] pattern matching.
  factory KSError.builder(String? Function(KSIssue issue) builder) =
      _KSErrorBuilder;

  /// Resolves the error for the given [issue].
  String? resolve(KSIssue issue);
}

final class _KSErrorText implements KSError {
  _KSErrorText(this.text);

  final String text;

  @override
  String? resolve(KSIssue issue) => text;
}

final class _KSErrorBuilder implements KSError {
  _KSErrorBuilder(this.builder);

  final String? Function(KSIssue issue) builder;

  @override
  String? resolve(KSIssue issue) => builder(issue);
}

/// Thrown when an asynchronous refinement rule is executed during synchronous validation.
class KSAsyncValidationError implements Exception {
  const KSAsyncValidationError([
    this.message = 'Async refinement used during synchronous validation. Use validateAsync() or validateMapAsync() instead.',
  ]);

  final String message;

  @override
  String toString() => 'KSAsyncValidationError: $message';
}
