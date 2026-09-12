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
  /// On failure, [onInvalid] runs if given; otherwise the first visible
  /// error is revealed (scrolled to and focused) via the ambient
  /// `KeyedFieldRegistry` — no registry to construct or pass, [KeyedForm]
  /// owns one internally.
  ///
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
    );
  }
}
