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
- `validateAsync` accepts optional `timeout` / `onFailure`. A thrown check, or
  one that exceeds `timeout`, marks the field `isFailedValidation`
  (`FieldHandle.isFailedValidation` / `KeyedFormController.isFailedValidation`)
  instead of propagating out of the returned `Future` or writing into
  `errors` — a technical fault is a different state from "the value is
  invalid". Not sticky: the next `validateAsync` call on the same field
  clears it, whether that call succeeds or fails in turn.
- `form.field(ref).markReadOnly()` / `.unmarkReadOnly()` / `.isReadOnly` (and
  `KeyedFormController.markReadOnly` / `unmarkReadOnly` / `isReadOnly`) freeze
  a field — and, by `FieldKey` ancestor coverage, everything nested under it —
  against `set` / `update` / list mutation, without affecting validation.
  Pass `force: true` to `set` / `update` (and to every `KeyedFormList`
  mutator) to write through the freeze anyway. Read-only status is
  configuration: `seed()` / `reset()` deliberately leave it in place, unlike
  the touched / revealed / validating / failed bookkeeping they clear.
- `form.addRelation(source, select, onChange)` — calls `onChange` with the
  selected, `==`-deduplicated slice of `source` whenever it actually changes.
  Registering the relation does not itself call `onChange`. Returns a
  callback that unsubscribes it — call that from your own `dispose()`, since
  the controller does not track relations for you. Skips silently while
  `source` does not resolve (for example, a row that has been removed from a
  list).
