import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:listen/listen.dart';

import 'keyed_form_controller.dart';

/// Keeps a derived value in sync with a slice of another field.
extension KeyedFormRelations<Root> on KeyedFormController<Root> {
  /// Calls [onChange] with `select(value)` every time that derived value
  /// actually changes (compared with `==`). Registering the relation does not
  /// itself call [onChange] — only a later change to [source] does.
  ///
  /// Silently does nothing while [source] does not resolve (for example, a
  /// row that has been removed from a list) — it neither calls [onChange] nor
  /// treats the gap as a value to compare against once [source] resolves
  /// again.
  ///
  /// Returns a callback that unsubscribes the relation. This controller does
  /// not track or dispose relations for you — call the returned callback from
  /// your own `dispose()`.
  VoidCallback addRelation<S, D>(
    FieldRef<Root, S> source,
    D Function(S value) select,
    void Function(D value) onChange,
  ) {
    // Primed from the current value so the first notification after
    // registration — whatever field it was about — is compared against a
    // real baseline instead of firing unconditionally.
    final initial = read(source);
    var hasLast = initial != null;
    D? last = initial == null ? null : select(initial);

    void listener() {
      final value = read(source);
      if (value == null) return;
      final next = select(value);
      if (hasLast && next == last) return;
      hasLast = true;
      last = next;
      onChange(next);
    }

    addListener(listener);
    return () => removeListener(listener);
  }
}
