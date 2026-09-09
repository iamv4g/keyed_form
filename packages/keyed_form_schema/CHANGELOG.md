## 0.1.0

Initial release.

- Fluent schema DSL: `ks.object`, `ks.string`, `ks.int`, `ks.double`,
  `ks.num`, `ks.boolean`, `ks.enums`, `ks.list`, `ks.map`,
  `ks.discriminatedUnion`.
- `validateMap` / `validateMapAsync` — validate a raw `Map` (e.g. a decoded
  JSON body), yielding `FieldKey`-addressed `FieldErrors`.
- `validateValues` / `validateValuesAsync` — validate from a positional list
  of field values in schema field order, allocating no map. This is what the
  `keyed_form_gen` `validate()` calls on every keystroke; `KSObject` caches
  its per-field `FieldKey`s and field list so a validation run does no
  per-field key/iterator allocation.
- Cross-field `.refine(...)` with sync / async predicates (the refinement
  callbacks still receive the whole map, rebuilt lazily only when one runs).
- i18n-friendly lazy message resolution (`error: .text(...)` /
  `error: .builder(...)`).
