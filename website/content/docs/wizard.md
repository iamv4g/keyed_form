---
title: Multi-step forms
description: Keep one controller above the step switch so values survive when step widgets are replaced.
---

A wizard can replace the visible step subtree while one `KeyedFormController` remains alive in the parent state. The draft stays in the controller, not in the temporary text field widget.

## Validate before advancing

Touch the fields for the current step, then check their errors before changing the step. On the last step, submit the complete form:

```dart
void next() {
  form.touch(CheckoutFields.customerName.key);
  if (form.field(CheckoutFields.customerName).error == null) {
    setState(() => currentStep++);
    return;
  }

  form.handleSubmit(context, (data) async {
    await api.submitOrder(data);
  });
}
```

Set the controller's initial value, mode, and schema resolver once. Dispose it when the wizard screen is removed.
