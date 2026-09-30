---
title: Form scope and context
description: Publish a controller and field registry to descendants and use the correct BuildContext for lookups and submit.
---

`KeyedForm<Root>` publishes its `KeyedFormController<Root>`, owns the field-anchor registry, and installs the reactive scope used by context selectors. `KeyedForm.controllerOf`, `registryOf`, and `translateErrorOf` perform an ambient lookup: their context must be below the matching `KeyedForm` in the widget tree.

A `State.context` that created the `KeyedForm` is above it and cannot perform that lookup. Use a descendant builder context instead:

```dart
KeyedForm<InvoiceSchema>(
  controller: form,
  child: Builder(
    builder: (formContext) => FilledButton(
      onPressed: () => form.handleSubmit(formContext, saveInvoice),
      child: const Text('Save'),
    ),
  ),
)
```

`handleSubmit` also requires this descendant context. By default it reveals the first visible error using the registry owned by the form; a supplied `onInvalid` callback takes responsibility for invalid handling instead. The registry and form scope are created and disposed with the `KeyedForm` state; the controller is passed in by the application. Keep ownership clear: dispose a controller you created when its owning screen is disposed, not from an arbitrary field builder.

`translateError` is a stable, non-reactive function reference. Changing its identity does not re-propagate a new translator through existing descendants. See [submit and scroll to error](docs/flutter/scroll-to-first-error) and [field bindings](docs/flutter/field-bindings).
