## 0.2.0

- `refine(path: ...)` is now checked against the schema's declared fields at
  generation time, including dotted paths into nested objects
  (`'stop.city'`). A path that doesn't resolve to a real field used to be a
  silent no-op — the refinement's error never attached to any field — so it
  now fails the build instead, naming the closest field if one looks like a
  typo.

- Generated list-row accessors (`<Root>Fields.<accessor>(...)`) now take
  named `<field>ClientId` parameters instead of an `<Accessor>Ref` record —
  `TourFields.stop(stopClientId: id)` instead of
  `final ref = (stop: id); TourFields.stop(ref)`. The `<Accessor>Ref`
  typedef is gone. Re-run `build_runner build` and update call sites
  accordingly.

- Generated doc comments no longer say "affine" — the form layer doesn't
  use `keyed_lens` vocabulary, so a row accessor's doc now just says its
  read/write is a no-op when the row doesn't exist.

## 0.1.0

Initial release.

- `build_runner` generator for `@keyedSchema`-annotated libraries: turns each
  `ks.object({...})` schema into an immutable data class (`const` constructor,
  `.create()` factory with auto `clientId`, `copyWith`, `==`, `hashCode`,
  `toMap`).
- A `<Root>Fields` namespace of `keyed_form_core` field references —
  `StrictFieldRef` for scalars, `<Field>FieldRefs` wrappers for nested objects
  and list rows, `.asVariant` narrowers for discriminated unions.
- `validate([scope])` / `validateAsync([scope])` and the `validateData` /
  `validateDataAsync` statics, returning `FieldErrors`. They pass a
  `_validationValues` list (the object's field values in schema order) to
  `KSObject.validateValues`, so no `Map` is built per validation; `toMap()`
  stays the serialization path. Passing a `FieldKey` scope re-checks only that
  subtree. `<Root>.validateData` is assignable straight to
  `KeyedFormController.resolver`, and `<Root>.scopeOf` (delegating to
  `rowScopeOf`) is a ready default `scopeOf`.
- `copyWith` is a typed public interface backed by a private sentinel-based
  implementation so bare `[]` / `{}` literals infer correctly at call sites.
