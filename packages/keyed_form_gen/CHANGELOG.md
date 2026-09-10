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
