## Unreleased

- `KSObject` validation perf: the per-field `FieldKey`s and the field list are
  computed once per schema instead of rebuilt on every `validateMap` call.
  At 100 flat fields this cuts `validateMap` ~5× (≈15 µs → ≈3 µs), so a
  generated model's per-keystroke `validateData` drops from ~28 µs to ~20 µs
  (now on par with `reactive_forms`). See `benchmark/`.

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
