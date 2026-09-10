import 'package:keyed_lens/keyed_lens.dart' show FieldKey, IdSegment;

/// The subtree a scoped `KeyedFormController` should re-validate for a write to
/// [writtenKey].
///
/// - inside a by-id list row → that row (the deepest one the key sits in), so
///   editing one row re-validates only it;
/// - otherwise → the top-level field;
/// - a root write → `null`, i.e. fall back to whole-draft validation.
///
/// This is the default `scopeOf` the generator wires up as `<Schema>.scopeOf`;
/// pass your own lambda for a coarser or finer unit.
FieldKey? rowScopeOf(FieldKey writtenKey) {
  final segments = writtenKey.segments;
  if (segments.isEmpty) return null;
  for (var i = segments.length - 1; i >= 0; i--) {
    if (segments[i] is IdSegment) return writtenKey.prefix(i + 1);
  }
  return writtenKey.prefix(1);
}
