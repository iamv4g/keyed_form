## 0.1.0

Initial release.

- `KeyedForm` — the `Form` of this family. Publishes a `KeyedFormController`
  down the widget tree and owns a `KeyedFieldRegistry` internally (apps never
  construct one); `KeyedForm.controllerOf` / `registryOf` /
  `translateErrorOf` read it back from a *descendant* context (the `context`
  a builder callback hands you — same rule as `Form.of(context)`).
- `KeyedFormField` (and `KeyedFormField.text`) — binds one field reference and
  rebuilds only when that field's value or visible error changes.
- `KeyedFieldList` — binds one list field and rebuilds only when the row set
  changes.
- `context.watchField(ref)` / `context.watchForm<Root>()` /
  `context.selectForm((f) => slice)` — read a form slice in `build()`, get the
  value back, rebuild this element only when *that* changes. The react-hook-form
  `watch` / bloc `context.select` of this family (same selective-`InheritedElement`
  machinery as `provider`).
- `KeyedFormSelector<Root, T>` — scopes a `context.selectForm` rebuild to a
  subtree (`provider`'s `Selector` alongside `context.select`); has a
  non-rebuilt `child`.
- `KeyedFormBuilder<Root>` — the whole-form escape hatch (rebuilds on every
  controller change).
- `KeyedTextBinding` — a caret- and IME-stable `TextEditingController` binding.
- `KeyedFieldRegistry` / `KeyedFieldAnchor` — scroll-to-first-error.
- `form.handleSubmit(context, onValid, {onInvalid})` — the react-hook-form
  `handleSubmit` of this family: wraps `KeyedFormController.submit` with a
  default `onInvalid` that reveals the first visible error via the ambient
  `KeyedFieldRegistry`; pass `onInvalid` to override for custom
  invalid-handling (e.g. scrolling a lazily-built section list first).
