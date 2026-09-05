/// The Flutter binding for `keyed_form`.
///
/// Wrap an editor subtree in a [KeyedFormScope] to publish its [KeyedFormController],
/// then address individual fields with [KeyedFormField] and lists with
/// [KeyedFieldList] — each rebuilds only when its own slice of the form
/// changes. [KeyedTextBinding] and [KeyedFieldRegistry] cover caret-stable text
/// input and scroll-to-first-error.
///
/// Re-exports all of `keyed_form` (and thus `keyed_lens`), so a screen needs a
/// single import.
library;

export 'package:keyed_form/keyed_form.dart';

export 'src/keyed_text_binding.dart';
export 'src/keyed_field_registry.dart';
export 'src/keyed_form_scope.dart';
export 'src/keyed_field_list.dart';
export 'src/keyed_form_field.dart';
