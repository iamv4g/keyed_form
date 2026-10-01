## 0.2.0

Breaking validation lifecycle update, matching `keyed_form` 0.2.0.

- `KeyedFormField` and `KeyedFieldState` continue to expose validation progress
  and technical-failure state, now driven by configured controller rules.
- `handleSubmit` routes blocking technical failures to
  `onValidationUnavailable`; value errors still use `onInvalid`, whose
  default behavior reveals the first visible error.
- `KeyedFormField` and `.text` detect focus leaving the field subtree by
  default. Set `autoDetectBlur: false` when a control owns a wider logical
  focus lifecycle, then call `KeyedFieldState.onBlur` at its logical boundary.
- `KeyedFieldState.onBlur` remains safe after its field binding disappears.
- Text-field examples rely on the binding's focus boundary; `onTapOutside`
  only moves focus, and Enter/submission does not simulate blur.
- Add pub.dev topics for package discoverability.

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
