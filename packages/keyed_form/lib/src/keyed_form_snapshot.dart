import 'package:keyed_lens/keyed_lens.dart';
import 'package:meta/meta.dart';

/// An immutable, point-in-time copy of a [KeyedFormController]'s coarse state.
///
/// The controller itself is a `ChangeNotifier`, not a value — a host that
/// prefers to expose an immutable value (a Riverpod `Notifier` whose `state`
/// must have identity semantics, a `==`-based rebuild guard) can listen to the
/// controller and republish [KeyedFormController.snapshot] on every change.
///
/// It deliberately omits the touched/revealed/mode bookkeeping: per-field
/// error *visibility* is a question for [KeyedFormController.visibleError], asked
/// from inside the form subtree, not something to thread through app state.
@immutable
class KeyedFormSnapshot<Root> {
  const KeyedFormSnapshot({
    required this.value,
    required this.original,
    required this.errors,
    required this.isDirty,
    required this.submitted,
    required this.submitting,
  });

  final Root value;
  final Root original;
  final FieldErrors<String> errors;
  final bool isDirty;
  final bool submitted;
  final bool submitting;

  @override
  bool operator ==(Object other) =>
      other is KeyedFormSnapshot<Root> &&
      other.value == value &&
      other.original == original &&
      identical(other.errors, errors) &&
      other.isDirty == isDirty &&
      other.submitted == submitted &&
      other.submitting == submitting;

  @override
  int get hashCode => Object.hash(
    value,
    original,
    identityHashCode(errors),
    isDirty,
    submitted,
    submitting,
  );
}
