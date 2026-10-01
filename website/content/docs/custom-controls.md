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

For a dropdown, slider, or stepper, use the same pattern and choose one blur
owner. `KeyedFormField` detects focus leaving its widget subtree by default.
Set `autoDetectBlur: false` when the control commits at a logical boundary
outside that subtree, then call `onBlur()` at that boundary. Show `errorText`
where appropriate and honor `isReadOnly`.
