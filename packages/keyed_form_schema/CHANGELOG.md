## 0.1.0

Initial release.

- Fluent schema DSL: `ks.object`, `ks.string`, `ks.int`, `ks.double`,
  `ks.num`, `ks.boolean`, `ks.enums`, `ks.list`, `ks.map`,
  `ks.discriminatedUnion`.
- `validateMap` / `validateMapAsync` yielding `FieldKey`-addressed
  `FieldErrors`.
- Cross-field `.refine(...)` with sync / async predicates.
- i18n-friendly lazy message resolution (`error: .text(...)` /
  `error: .builder(...)`).
