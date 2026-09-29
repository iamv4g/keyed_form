---
title: Relations
description: Keep derived fields synchronized with their source values using addRelation.
---

`addRelation` recomputes a dependent field when its source changes. It is useful for values such as invoice totals that should always match a list of line items.

```dart
final unsubscribe = form.addRelation(
  InvoiceFields.lineItems,
  (items) => items.fold<num>(
    0,
    (sum, item) => sum + item.quantity * item.unitPrice,
  ),
  (total) => form.field(InvoiceFields.total).set(total, force: true),
);
```

## Manage the relation lifecycle

Keep the returned callback and invoke it when the relation is no longer needed, typically during `dispose`. If users must not edit the derived value directly, mark that field read only.

## Avoid manual listener loops

Register the calculation once instead of listening to controller changes and writing back from a broad listener. The relation declares its source, computation, and destination together.
