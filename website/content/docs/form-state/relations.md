---
title: Relations
description: Keep a derived field synchronized with a selected value from a source field.
---

`addRelation(source, select, onChange)` observes a source ref and calculates a derived value. The callback runs only when the selected result changes according to `==`. Registration does not invoke it, so initialize the destination explicitly from the current draft before relying on subsequent updates.

```dart
late final VoidCallback unsubscribeTotal;

void startRelations() {
  form.field(InvoiceFields.total).markReadOnly();
  final lines = form.value.lineItems;
  form.field(InvoiceFields.total).set(
    lines.fold<num>(0, (sum, line) => sum + line.quantity * line.unitPrice),
    force: true,
  );
  unsubscribeTotal = form.addRelation(
    InvoiceFields.lineItems,
    (items) => items.fold<num>(
      0,
      (sum, line) => sum + line.quantity * line.unitPrice,
    ),
    (total) => form.field(InvoiceFields.total).set(total, force: true),
  );
}

void dispose() {
  unsubscribeTotal();
  form.dispose();
}
```

A readonly destination requires a forced handle write, because relations do not bypass the normal write guard. The field remains validated normally. The returned callback removes the listener; the controller does not track or dispose relations automatically, so call it when the relation's owner ends.

If the source path does not resolve—for example, a row was removed or a nullable parent is absent—the relation does nothing. A missing source is not treated as a comparable value; when it resolves later, its selected value establishes a new baseline and can invoke the callback. Avoid broad controller-listener loops when a relation captures the intended dependency clearly.

For a source value that drives a dependent selection and reset workflow, see [Cascading dropdowns](docs/guides/cascading-dropdowns).
