---
title: Selective rebuilds
description: Observe only the form-state slice a widget needs to avoid rebuilding unrelated controls.
---

`context.watchField(ref)` observes one field, `context.watchForm()` observes the controller, and `context.selectForm(selector, equals:)` observes a derived slice. These extensions are available below a `KeyedForm`; they subscribe the calling element to the selected state, so use them in `build`, not as a one-time event-handler lookup.

```dart
KeyedFormSelector<CartSchema, bool>(
  selector: (form) => form.isDirty,
  builder: (context, dirty, child) => Text(dirty ? 'Unsaved' : 'Saved'),
)
```

`KeyedFormSelector` scopes that dependency to its own subtree and can carry a `child` that does not depend on the selected value. `KeyedFormBuilder` rebuilds on every controller change and is appropriate for a broad observer such as a state inspector, not a default wrapper around a large form.

By default, selection equality uses `==`. For a derived object or collection whose equality is identity-based or otherwise too broad, supply `equals` that compares the meaningful fields; otherwise equivalent outputs may trigger unnecessary rebuilds. Conversely, ensure the selector includes every value the rendered subtree reads. Read the latest controller value directly in an event handler when you need an action-time snapshot, rather than making a build dependency solely for that callback.

Individual [field bindings](docs/flutter/field-bindings) already rebuild for their own value or visible error, not sibling field changes. [KeyedFieldList](docs/flutter/long-lists) separately observes row set/order changes while fields observe row edits.
