/// A collection element addressed by a stable, client-side id rather than by
/// its index.
///
/// A [FieldKey] built from a row's [clientId] keeps pointing at the same row
/// across insert/remove/move of its siblings — and a write through a stale
/// reference no-ops instead of hitting the wrong row (the affine law that
/// [ListItemLens] enforces). `keyed_form_gen` marks every generated list-item
/// class `implements KeyedRow`.
abstract interface class KeyedRow {
  String get clientId;
}
