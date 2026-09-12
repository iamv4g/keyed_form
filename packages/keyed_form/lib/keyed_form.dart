/// A form-state controller for immutable aggregates — the react-hook-form of
/// the `keyed_form` family.
///
/// [KeyedFormController] owns the editable draft, the field-keyed validation errors,
/// and the touched/dirty/revealed bookkeeping that decides *when* an error is
/// shown. Field identity, reads and writes go through the `FieldRef` vocabulary
/// from `keyed_form_core`, which this library re-exports.
///
/// Pure Dart: observability is `ChangeNotifier` from `package:listen`, so the
/// controller can live in a plain Dart test, a CLI, or — via
/// `keyed_form_flutter` — a widget tree.
library;

export 'package:keyed_form_core/keyed_form_core.dart'
    hide KeyedSchema, keyedSchema;

export 'src/field_handle.dart';
export 'src/keyed_form_controller.dart';
export 'src/keyed_form_list.dart';
export 'src/keyed_form_mode.dart';
export 'src/keyed_form_relations.dart';
export 'src/keyed_form_resolver.dart';
export 'src/keyed_form_snapshot.dart';
