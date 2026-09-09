## Unreleased

- `FieldKey.hashCode` is now cached (computed once per instance) — keys are
  used as `Map` / `Set` keys on every validation, touch check and error
  lookup. `==` also early-outs on a hash mismatch.

## 0.1.0

Initial release.

- `FieldKey` + sealed `Segment` (`NameSegment` / `IdSegment`) — stable,
  serializable field identity with a frozen `toPath()` / `parse()` wire codec.
- `Lens` (total) / `AffineLens` (affine) with `then` / `thenTotal` composition;
  affine `set` / `update` no-op on a non-resolving path.
- `ListItemLens` + `.at(id, matches)` — by-id list-row access.
- `Prism` — minimal type-narrowing optic for sum types.
- `whenPresent()`, `Opt` (`Some` / `None`), `KeyedRow`.
