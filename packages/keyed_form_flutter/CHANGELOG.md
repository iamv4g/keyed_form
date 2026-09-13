## 0.1.0

Initial release.

- `KeyedForm` — the `Form` of this family. Publishes a `KeyedFormController`
  down the widget tree and owns a `KeyedFieldRegistry` internally (apps never
  construct one); `KeyedForm.controllerOf` / `registryOf` /
  `translateErrorOf` read it back from a *descendant* context (the `context`
  a builder callback hands you — same rule as `Form.of(context)`).
- `KeyedFormField` (and `KeyedFormField.text`) — binds one field reference and
  rebuilds only when that field's value, visible error, or `isValidating`
  changes. `KeyedFieldState.isValidating` mirrors
  `KeyedFormController.isValidating` — render a spinner from it while a
  field's own async validation (`form.field(ref).validateAsync`) is running.
- `KeyedFieldState.isFailedValidation` mirrors
  `KeyedFormController.isFailedValidation` — render a retry affordance from
  it when a field's async check itself failed (it threw, or exceeded its
  timeout), as distinct from `errorText`.
- `KeyedFieldState.isReadOnly` mirrors `KeyedFormController.isReadOnly` — pass
  `enabled: !state.isReadOnly` to the wrapped Material widget to grey it out.
  `onChanged` stays safe to wire unconditionally: the controller already
  no-ops a write to a frozen field.
- `KeyedFieldList` — binds one list field and rebuilds only when the row set
  changes.
- `context.watchField(ref)` / `context.watchForm<Root>()` /
  `context.selectForm((f) => slice)` — read a form slice in `build()`, get the
  value back, rebuild this element only when *that* changes: a selective read
  built on the same `InheritedElement` machinery as Flutter's scoped-rebuild
  widgets.
- `KeyedFormSelector<Root, T>` — scopes a `context.selectForm` rebuild to a
  subtree; has a non-rebuilt `child`.
- `KeyedFormBuilder<Root>` — the whole-form escape hatch (rebuilds on every
  controller change).
- `KeyedTextBinding` — a caret- and IME-stable `TextEditingController` binding.
- `KeyedFieldRegistry` / `KeyedFieldAnchor` — scroll-to-first-error.
- `form.handleSubmit(context, onValid, {onInvalid})` — wraps
  `KeyedFormController.submit` with a default `onInvalid` that reveals the
  first visible error via the ambient `KeyedFieldRegistry`; pass `onInvalid`
  to override for custom invalid-handling (e.g. scrolling a lazily-built
  section list first).
