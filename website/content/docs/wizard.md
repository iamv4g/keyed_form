---
title: Multi-step forms
description: Keep one controller above the step switch so values survive when step widgets are replaced.
---

A wizard can replace the visible step subtree while one `KeyedFormController` remains alive in the parent state. The draft stays in the controller, not in the temporary text field widget.

## Validate before advancing

Touch the fields for the current step, then check their errors before changing the step. On the last step, submit the complete form:

```dart
void next() {
  if (currentStep == 0) {
    form.touch(CheckoutFields.customerName.key);
    if (form.field(CheckoutFields.customerName).error == null) {
      setState(() => currentStep++);
    }
  } else {
    form.handleSubmit(context, (data) async {
      await api.submitOrder(data);
    });
  }
}
```

The step check matters: validate only the fields for the current step before advancing, then submit the complete form on the last step. Keep the controller above the switched step subtree, set its initial value, mode, and schema resolver once, and dispose it when the wizard screen is removed.
