## 0.1.0

Initial release.

- `KeyedFormController<Root>` — owns the editable draft, the `FieldKey`-keyed
  validation errors, and the touched / dirty / revealed bookkeeping that
  decides when an error is shown.
- `form.field(ref)` — a statically-typed per-field facade (`FieldHandle`):
  `set` / `update` / `value` / `error` / `dirty` / `key` / `touch()`, plus
  `list()` / `dirtyRows()` for a list field. `.set(value)` rejects a
  wrongly-typed value at compile time. The raw primitives it funnels through
  (`setField` / `updateField` / `list` / `mutateList`) are `@internal` — a
  Dart inference hole means calling them directly would not catch a type
  mismatch until runtime; they become public again once the `variance`
  language feature lands (see the note in `keyed_form_controller.dart`).
- `KeyedFormMode` — when a field's error becomes visible.
- Scoped validation via `KeyedFormResolver` / `KeyedFormScopeOf`.
- `KeyedFormList` — by-id list editing (append / insert / remove / move /
  update).
- `KeyedFormSnapshot` — an immutable copy of the coarse state.
