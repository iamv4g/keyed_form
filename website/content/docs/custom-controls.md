---
title: Custom controls
description: Bind switches, sliders, and other controls through a typed field handle.
---

Use `KeyedFormField<Root, Value>` when the control is not a text input. Read the value and report changes through the field binding:

```dart
KeyedFormField<SettingsSchema, bool>(
  field: SettingsFields.notifications,
  builder: (context, field) => SwitchListTile(
    value: field.value ?? false,
    onChanged: field.isReadOnly ? null : field.onChanged,
    title: const Text('Notifications'),
  ),
)
```

For a dropdown, slider, or stepper, use the same pattern: provide a stable typed field, show `errorText` where appropriate, honor `isReadOnly`, and call `onBlur()` when the control loses focus if the validation mode depends on touch state.
