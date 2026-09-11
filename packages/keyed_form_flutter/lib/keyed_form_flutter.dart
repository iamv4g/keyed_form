/// The Flutter binding for `keyed_form`.
///
/// Wrap an editor subtree in a [KeyedForm] to publish its
/// [KeyedFormController], then:
///
/// * bind an input with [KeyedFormField] / a list with [KeyedFieldList];
/// * read a slice in `build()` with `context.watchField(ref)` /
///   `context.watchForm()` / `context.selectForm((f) => …)` — the
///   react-hook-form `watch` / bloc `context.select` of this family;
/// * or scope that to a subtree with the [KeyedFormSelector] widget, or watch
///   the whole controller with [KeyedFormBuilder].
///
/// Each rebuilds only when its own slice changes. [KeyedTextBinding] and
/// [KeyedFieldRegistry] cover caret-stable text input and scroll-to-error.
///
/// Re-exports all of `keyed_form` (and thus `keyed_form_core`), so a screen needs a
/// single import.
library;

export 'package:keyed_form/keyed_form.dart';

export 'src/keyed_text_binding.dart';
export 'src/keyed_field_registry.dart';
export 'src/keyed_form.dart';
export 'src/keyed_field_list.dart';
export 'src/keyed_form_context.dart' show KeyedFormContext;
export 'src/keyed_form_field.dart';
export 'src/keyed_form_selector.dart';
