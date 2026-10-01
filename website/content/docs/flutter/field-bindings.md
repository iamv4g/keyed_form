---
title: Field bindings and custom controls
description: Bind switches, pickers, and custom controls through typed field state.
---

Use `KeyedFormField<Root, Value>` for a non-text control. Its builder receives `KeyedFieldState<Value>` with the current nullable value, `onChanged`, `onBlur`, translated `errorText`, `fieldKey`, `isReadOnly`, `isValidating`, and `isFailedValidation`.

```dart
KeyedFormField<SettingsSchema, bool>(
  field: SettingsFields.notifications,
  builder: (context, field) => SwitchListTile(
    value: field.value ?? false,
    onChanged: field.isReadOnly ? null : field.onChanged,
    title: const Text('Notifications'),
    subtitle: field.errorText == null ? null : Text(field.errorText!),
  ),
)
```

`KeyedFormField` reports focus leaving its widget subtree automatically by
default, including for text inputs; ordinary fields need no extra `Focus`
wrapper. `onTapOutside` should only unfocus and does not cover keyboard focus
traversal. For a picker whose logical focus extends into an overlay, set
`autoDetectBlur: false` and call `onBlur()` when that interaction ends.
`onChanged` writes the new value through the controller; frozen fields safely
ignore writes, but disabling the control gives users the expected visual
feedback. `isValidating` and `isFailedValidation` describe configured async
rule progress and technical failure; they are not substitutes for `errorText`.

The builder result is wrapped in a `KeyedFieldAnchor` automatically, registered under `fieldKey`. This allows submit handling to reveal a mounted invalid control without manual registry wiring. Set `anchor: false` only when this widget must never be a scroll-to-error target (for example, a decorative duplicate representation); it disables that automatic anchor. See [submit and scroll to error](docs/flutter/scroll-to-first-error).

For a text input, prefer [text binding](docs/flutter/text-binding), which owns the editing controller and handles external updates without duplicate change reporting.
