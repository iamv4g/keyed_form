import 'package:keyed_form_core/keyed_form_core.dart';

import 'keyed_form_mode.dart';

/// Why a remote or otherwise asynchronous validation could not produce a
/// verdict about the field value.
final class KeyedFormValidationFailure {
  const KeyedFormValidationFailure({
    required this.error,
    required this.stackTrace,
    required this.failureMode,
  });

  final Object error;
  final StackTrace stackTrace;
  final KeyedFormAsyncFailureMode failureMode;
}

/// Immutable outcome of one explicit or submit validation run.
final class KeyedFormValidationResult {
  const KeyedFormValidationResult({
    required this.status,
    required this.errors,
    required this.failures,
  });

  final KeyedFormValidationStatus status;
  final FieldErrors<String> errors;
  final Map<FieldKey, KeyedFormValidationFailure> failures;

  /// True only when applicable value checks produced no errors or failures.
  bool get isValid => status == KeyedFormValidationStatus.valid;
}
