---
title: Multi-step forms
description: Keep one controller above the step switch so values survive when step widgets are replaced.
---

A wizard can replace the visible step subtree while one `KeyedFormController` remains alive in the parent state. The draft stays in the controller, not in the temporary text field widget.

## Validate before advancing

Validate a step explicitly before advancing, then submit the full draft on the
last step:

```dart
Future<void> next() async {
  if (currentStep == 0) {
    final result = await form.validateScopes([
      CheckoutFields.customerName.key,
    ]);
    if (result.isValid) setState(() => currentStep++);
  } else {
    await form.handleSubmit(context, (data) async {
      await api.submitOrder(data);
    });
  }
}
```

`validateScopes` returns a structured result; it does not return a list of
failing keys. Keep the controller above the switched step subtree, set its
initial value, mode, and schema resolver once, and dispose it when the wizard
screen is removed. See [Validation and visibility](docs/form-state/validation)
for scoped validation behavior.
