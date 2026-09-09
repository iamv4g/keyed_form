## Unreleased

- `KSObject` validation perf:
  - the per-field `FieldKey`s and the field list are computed once per schema
    instead of rebuilt on every `validateMap` call;
  - new `validateValues(List<Object?> orderedValues)` /
    `validateValuesAsync` — validates from a positional list of field values
    (in schema field order) instead of a `Map`, so the generated `validate()`
    no longer builds a map per call. `validateMap` gains an internal
    `orderedValues` parameter and is otherwise unchanged.
  At 100 flat fields the two changes take a generated model's per-keystroke
  `validateData` from ~28 µs to ~11 µs (JIT) / ~3.6 µs (AOT) — level with a
  hand-written resolver, ~2× faster than `reactive_forms`. See `benchmark/`.

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
