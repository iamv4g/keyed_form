/// Which user event automatically starts validation before and after submit.
enum KeyedFormMode {
  /// Validate after each write. After the first submit attempt, the configured
  /// [KeyedFormReValidateMode] controls automatic revalidation instead.
  onChange,

  /// Validate when a field loses focus. After the first submit attempt, the
  /// configured [KeyedFormReValidateMode] controls automatic revalidation.
  onBlur,

  /// Validate on a field's first blur, then on writes to fields that have
  /// blurred. After submit, [KeyedFormReValidateMode] controls revalidation.
  onTouched,

  /// Do not validate automatically before submit. After the first submit
  /// attempt, [KeyedFormReValidateMode] controls automatic revalidation.
  onSubmit,

  /// Validate after every write and blur, both before and after submit;
  /// this continues to trigger both events regardless of revalidate mode.
  all,
}

/// Events that automatically rerun validation after a submit attempt settles.
enum KeyedFormReValidateMode {
  /// Revalidate after every write.
  onChange,

  /// Revalidate when a field loses focus.
  onBlur,

  /// Do not automatically revalidate after submit; the next submit still
  /// validates the current draft.
  onSubmit,
}

/// Whether a technical async-validation failure prevents a valid-value
/// submission.
enum KeyedFormAsyncFailureMode {
  /// Block `onValid` when a check fails technically and route to
  /// `onValidationUnavailable`. Value errors block submission either way.
  blockSubmit,

  /// Permit `onValid` when no value errors remain, even if a check failed.
  /// The result remains unavailable; the server may still reject the value.
  allowSubmit,
}

/// Outcome category for an explicit or submit validation run.
enum KeyedFormValidationStatus {
  /// Every applicable check completed without a value error or technical
  /// failure.
  valid,

  /// At least one value error exists. Technical failures may also be present.
  invalid,

  /// No value error exists, but one or more applicable checks failed
  /// technically, including checks configured with `allowSubmit`.
  unavailable,

  /// The run was invalidated before settling. It must not authorize a submit.
  superseded,
}
