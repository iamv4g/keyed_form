---
title: Relations
description: Keep derived fields synchronized with their source values using addRelation.
---

`addRelation` recomputes a dependent field when its source changes. It is useful for values such as invoice totals that should always match a list of line items.

```dart
late final VoidCallback unsubscribeTotal;

void initRelations() {
  form.field(InvoiceFields.total).markReadOnly();
  unsubscribeTotal = form.addRelation(
    InvoiceFields.lineItems,
    (items) => items.fold<num>(
      0,
      (sum, item) => sum + item.quantity * item.unitPrice,
    ),
    (total) => form.field(InvoiceFields.total).set(total, force: true),
  );

  // Registration watches future changes; it does not run the callback now.
  form.field(InvoiceFields.total).set(
    form.value.lineItems.fold<num>(
      0,
      (sum, item) => sum + item.quantity * item.unitPrice,
    ),
    force: true,
  );
}

void dispose() {
  unsubscribeTotal();
  form.dispose();
}
```

## Manage the relation lifecycle

`addRelation` does not invoke its callback on registration. Initialize the derived field from the current source value, as above, then the relation keeps it synchronized with later source changes. Keep the returned callback and invoke it when the relation is no longer needed, typically during `dispose`. A read-only derived field needs `force: true` for relation writes; validation still applies to read-only fields.

## Avoid manual listener loops

Register the calculation once instead of listening to controller changes and writing back from a broad listener. The relation declares its source, computation, and destination together.
