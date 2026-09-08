## Unreleased

- Field widgets now write through `controller.field(ref).set(...)` /
  `.list()` (the `keyed_form` per-field facade) instead of the now-`@internal`
  `setField` / `list`. No public API change.

## 0.1.0

Initial release.

- `KeyedFormScope` — publishes a `KeyedFormController` and a
  `KeyedFieldRegistry` down the widget tree.
- `KeyedFormField` (and `KeyedFormField.text`) — binds one field reference and
  rebuilds only when that field's value or visible error changes.
- `KeyedFieldList` — binds one list field and rebuilds only when the row set
  changes.
- `KeyedTextBinding` — a caret- and IME-stable `TextEditingController` binding.
- `KeyedFieldRegistry` / `KeyedFieldAnchor` — scroll-to-first-error.
