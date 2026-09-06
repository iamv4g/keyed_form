## 0.1.0

Initial release. Shared vocabulary for the `keyed_form` family:

- `FieldRef` / `StrictFieldRef` / `VariantRef` — field-reference aliases over
  the `keyed_lens` optics.
- `DelegatingFieldRef` — base class the generated `<X>FieldRefs` wrappers
  extend.
- `.whenPresent()` / `.narrow()` / `.at()` extensions on `FieldRef`.
- `FieldErrors<E>` — a `FieldKey`-keyed sidecar map, looked up by field
  reference.
- `@keyedSchema` / `KeyedSchema` — the annotation `keyed_form_gen` reads.
