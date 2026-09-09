## 0.1.0

Initial release.

- `FieldKey` + sealed `Segment` (`NameSegment` / `IdSegment`) — stable,
  serializable field identity with a frozen `toPath()` / `parse()` wire codec.
  `hashCode` is cached (a key is immutable and used as a `Map` / `Set` key on
  every validation, touch check and error lookup); `==` early-outs on a hash
  mismatch.
- `Lens` (total) / `AffineLens` (affine) with `then` / `thenTotal` composition;
  affine `set` / `update` no-op on a non-resolving path.
- `ListItemLens` + `.at(id, matches)` — by-id list-row access.
- `Prism` — minimal type-narrowing optic for sum types.
- `whenPresent()`, `Opt` (`Some` / `None`), `KeyedRow`.
