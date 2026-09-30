---
title: Text fields and bindings
description: Keep text editing controllers synchronized with form state without disrupting caret or IME input.
---

`KeyedFormField.text<Root>` combines a typed form field with a managed `TextEditingController`. The builder receives the field state and controller; use the controller on the text widget and render `errorText` as usual. The binding lifecycle follows the field widget and cleans up its controller when disposed. See the working [login text field source](https://github.com/tastech-sakura/keyed_form/blob/main/packages/keyed_form_flutter/example/lib/login/login_text_field.dart).

For a standalone control, `KeyedTextBinding` accepts a `value`, `onChanged`, and builder that receives its controller:

```dart
KeyedTextBinding(
  value: form.read(LoginFields.email) ?? '',
  onChanged: form.field(LoginFields.email).set,
  builder: (context, controller) => TextField(controller: controller),
)
```

Do not also wire the wrapped text widget's `onChanged` to the same form field: `KeyedTextBinding` listens to controller edits and reports them itself. It ignores selection/composing-only notifications, distinguishing user text edits from external values. When an external update (such as reset or server patch) changes the value, it only replaces controller text if needed, clamps the existing selection to the new length, and drops an IME composing region. Thus an external state update can end active composition, while routine rebuilds with unchanged text do not reset the caret.

Use the higher-level [field bindings](docs/flutter/field-bindings) API for a custom non-text control, or [selective rebuilds](docs/flutter/reactivity) when a widget only observes state.
