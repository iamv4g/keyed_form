## 0.1.0

Initial release.

- `KeyedFormScope` — publishes a `KeyedFormController` and a
  `KeyedFieldRegistry` down the widget tree.
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
