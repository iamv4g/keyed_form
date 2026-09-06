import 'package:keyed_form_core/keyed_form_core.dart';

/// Validates a draft and returns its field-keyed errors — the equivalent of a
/// react-hook-form `resolver` / a zod `safeParse`.
///
/// [scope] is the cooperation point for large aggregates that validate one
/// subtree at a time (a single line item, say):
///
/// - `scope == null` — validate the **whole** draft; the return value replaces
///   the controller's entire error map.
/// - `scope != null` — validate only the subtree at that key; the controller
///   drops its existing errors under [scope] and splices in the result,
///   preserving document order. Every returned key must be at or under
///   [scope] (asserted in debug).
///
/// A resolver that ignores [scope] and always validates everything is fine —
/// it just does more work than a scoped controller asks for.
typedef KeyedFormResolver<Root> =
    FieldErrors<String> Function(Root draft, FieldKey? scope);

/// Maps a just-written field's [FieldKey] to the subtree the controller should
/// re-validate, or `null` to fall back to a whole-draft validation.
///
/// Per-day editors pass `(key) => key.prefix(2)` so a write anywhere inside
/// `days.[id]. …` re-validates just that day.
typedef KeyedFormScopeOf = FieldKey? Function(FieldKey writtenKey);
