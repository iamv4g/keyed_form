## 0.1.0

Initial release.

- `FieldRef` / `StrictFieldRef` / `VariantRef` — field-reference `extension
  type`s over the `keyed_lens` optics, so IDE hover/autocomplete shows the
  field-reference vocabulary instead of the underlying optic types.
- `DelegatingFieldRef` — base class the generated `<X>FieldRefs` wrappers
  extend.
- `.whenPresent()` / `.narrow()` / `.at()` extensions on `FieldRef`.
- `FieldErrors<E>` — a `FieldKey`-keyed sidecar map, looked up by field
  reference.
- `rowScopeOf` — the default `KeyedFormController.scopeOf`: a write inside a
  by-id list row re-validates just that row, otherwise its top-level field.
- `@keyedSchema` / `KeyedSchema` — the annotation `keyed_form_gen` reads.
