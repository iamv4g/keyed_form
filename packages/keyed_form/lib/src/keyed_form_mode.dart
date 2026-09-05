/// When a field's validation error becomes *visible* — the same set of modes
/// as react-hook-form.
///
/// The controller never hides an error that a submit attempt surfaced, nor one
/// that was explicitly [KeyedFormController.reveal]ed; the mode only decides what
/// happens *before* that.
enum KeyedFormMode {
  /// Every write marks the written field touched, so its error shows as soon
  /// as the user changes it. Flat forms (login, profile info) use this.
  onChange,

  /// Errors show only after the field is touched. The widget layer calls
  /// [KeyedFormController.touch] on blur.
  onBlur,

  /// Same visibility rule as [onBlur] in the controller; the widget layer
  /// additionally keeps updating the error on every keystroke once the field
  /// has been blurred once. Per-row editors (line items, attachments)
  /// use this.
  onTouched,

  /// Errors show only after a submit attempt (or an explicit reveal).
  onSubmit,

  /// Errors show the moment they exist, regardless of touched state.
  all,
}
