---
title: Multi-step forms
description: Keep one controller across replaced steps and validate the current step without hiding later errors.
---

Keep a single `KeyedFormController` in the wizard's owning state, above the subtree that changes with the current step. Replacing step widgets then does not replace the draft or lose entered values.

## Configure scoped validation

A wizard should map writes to a scope that matches its validation unit. Generated `scopeOf` is useful for objects and keyed rows; for step-oriented forms, provide a resolver that honors the requested scope and a `scopeOf` mapping appropriate to your step boundaries. The resolver remains synchronous.

```dart
final form = KeyedFormController<CheckoutSchema>(
  initialValue: CheckoutSchema.create(),
  mode: KeyedFormMode.onSubmit,
  resolver: CheckoutSchema.validateData,
  scopeOf: CheckoutSchema.scopeOf,
);

final currentStepKeys = <FieldKey>[
  CheckoutFields.customer.key,
  CheckoutFields.address.key,
];

void nextStep() {
  if (form.validateScopes(currentStepKeys).isEmpty) {
    setState(() => currentStep++);
  }
}

Future<void> finish(BuildContext context) async {
  await form.submit((draft) => api.submitOrder(draft));
}
```

`CheckoutSchema.scopeOf` is only an example when generated scopes correspond to your wizard's units. If they do not, define a mapping from each written `FieldKey` to its step's scope and ensure the resolver validates that subtree. `validateScopes` force-reveals requested scopes and returns the scopes that still fail; the explicit result check works even in `onSubmit` visibility mode. Do not use an error that happens to be visible after touching fields as the gate for advancing.

The final action uses `submit`, which performs full-draft validation before invoking the callback; a valid current step does not imply that later steps are valid. Keep the controller alive for the whole wizard and dispose it with its owner. See [Validation and visibility](docs/form-state/validation) and [Flutter submit behavior](docs/flutter/scroll-to-first-error).
