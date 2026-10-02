import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_form.dart';

/// Flutter-aware convenience over [KeyedFormController.submit] — the
/// react-hook-form `handleSubmit` of this family.
extension KeyedFormHandleSubmit<Root> on KeyedFormController<Root> {
  /// Same contract as [submit]: validates, and on success runs [onValid]
  /// while toggling [KeyedFormController.submitting] around it.
  ///
  /// Value errors use [onInvalid] when given, otherwise the first visible
  /// error is revealed via the ambient `KeyedFieldRegistry`. Blocking
  /// technical failures use [onValidationUnavailable]; without that callback,
  /// fields whose checks failed are revealed instead.
  /// [context] must be a descendant of the [KeyedForm]`<Root>` this
  /// controller belongs to — the `context` a builder callback hands you
  /// (`KeyedFormSelector`, `KeyedFormBuilder`, a field's own builder), not
  /// the `context` of the [State] that *created* the [KeyedForm] (that one
  /// sits above it in the tree, so the lookup fails there — the same rule as
  /// Flutter's own `Form.of(context)`).
  Future<bool> handleSubmit(
    BuildContext context,
    FutureOr<void> Function(Root value) onValid, {
    FutureOr<void> Function(Iterable<FieldKey> errorKeys)? onInvalid,
    FutureOr<void> Function(KeyedFormValidationResult result)?
    onValidationUnavailable,
    Duration duration = const Duration(milliseconds: 300),
    double alignment = 0.1,
  }) {
    final registry = KeyedForm.registryOf<Root>(context);
    return submit(
      onValid,
      onInvalid:
          onInvalid ??
          (keys) => registry.revealFirst(
            keys,
            duration: duration,
            alignment: alignment,
          ),
      onValidationUnavailable:
          onValidationUnavailable ??
          (result) => registry.revealFirst(
            result.failures.entries
                .where(
                  (entry) =>
                      entry.value.failureMode ==
                      KeyedFormAsyncFailureMode.blockSubmit,
                )
                .map((entry) => entry.key),
            duration: duration,
            alignment: alignment,
          ),
    );
  }
}
