## Unreleased

- `form.field(ref)` — a statically-typed per-field facade (`FieldHandle`):
  `set` / `update` / `value` / `error` / `dirty` / `key` / `touch()`, plus
  `list()` / `dirtyRows()` for a list field. `.set(value)` rejects a
  wrongly-typed value at compile time, which `setField` could not.
- `setField` / `updateField` / `list` / `mutateList` on `KeyedFormController`
  are now `@internal` — the primitives behind `form.field(ref)`. They become
  public again once Dart's `variance` feature lands (see the note in
  `keyed_form_controller.dart`).

## 0.1.0

Initial release.

- `KeyedFormController<Root>` — owns the editable draft, the `FieldKey`-keyed
  validation errors, and the touched / dirty / revealed bookkeeping that
  decides when an error is shown.
- `KeyedFormMode` — when a field's error becomes visible.
- Scoped validation via `KeyedFormResolver` / `KeyedFormScopeOf`.
- `KeyedFormList` — by-id list editing (append / insert / remove / move /
  update).
- `KeyedFormSnapshot` — an immutable copy of the coarse state.
