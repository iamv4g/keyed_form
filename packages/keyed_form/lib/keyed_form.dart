/// A form-state controller for immutable aggregates — the react-hook-form of
/// the `keyed_lens` family.
///
/// [KeyedFormController] owns the editable draft, the field-keyed validation errors,
/// and the touched/dirty/revealed bookkeeping that decides *when* an error is
/// shown. Field identity, reads and writes go through the `FieldRef` (lens)
/// vocabulary from `keyed_lens`, which this library re-exports.
///
/// Pure Dart: observability is `ChangeNotifier` from `package:listen`, so the
/// controller can live in a plain Dart test, a CLI, or — via
/// `keyed_form_flutter` — a widget tree.
library;

export 'package:keyed_lens/keyed_lens.dart';

export 'src/keyed_form_controller.dart';
export 'src/keyed_form_list.dart';
export 'src/keyed_form_mode.dart';
export 'src/keyed_form_resolver.dart';
export 'src/keyed_form_snapshot.dart';
