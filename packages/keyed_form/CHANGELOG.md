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
- `form.submit(onValid, {onInvalid})` — validates, and on success runs
  `onValid` with the current value while toggling `submitting` around it; on
  failure runs `onInvalid` with the visible error keys, if given. Returns
  whether `onValid` ran. `keyed_form_flutter`'s `handleSubmit` wraps this
  with a Flutter-aware default `onInvalid` (scroll to the first error).
- `form.field(ref).isValidating` / `.validateAsync(check)` — per-field async
  validation (e.g. "is this email already taken?"), for the case a
  synchronous `resolver` can't cover. `validateAsync` toggles `isValidating`
  around `check`, merges a non-null result in as a server error on that
  field, and is safe against overlapping calls on the same field — a stale
  response can't clobber a newer one's result or reopen the spinner. The raw
  primitive underneath is `KeyedFormController.setFieldValidating`.
