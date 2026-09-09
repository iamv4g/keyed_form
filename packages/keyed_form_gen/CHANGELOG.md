## Unreleased

- Generated `validate()` / `validateAsync()` now pass a `_validationValues`
  list to `KSObject.validateReader` instead of `validateMap(toMap())` — no map
  is built per validation. `toMap()` is unchanged (still the serialization
  path). At 100 flat fields the generated per-keystroke `validateData` drops
  ~2.5× (see `benchmark/`); requires `keyed_form_schema` from this range.
  Re-run the generator to pick it up.

## 0.1.0

Initial release.

- `build_runner` generator for `@keyedSchema`-annotated libraries: turns each
  `ks.object({...})` schema into an immutable data class (`const` constructor,
  `.create()` factory with auto `clientId`, `copyWith`, `==`, `hashCode`,
  `toMap`).
- A `<Root>Fields` namespace of `keyed_form_core` field references —
  `StrictFieldRef` for scalars, `<Field>FieldRefs` wrappers for nested objects
  and list rows, `.asVariant` narrowers for discriminated unions.
- `validate()` / `validateAsync()` and the `validateData` statics, returning
  `FieldErrors`.
- `copyWith` is a typed public interface backed by a private sentinel-based
  implementation so bare `[]` / `{}` literals infer correctly at call sites.
