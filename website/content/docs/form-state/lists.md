---
title: List operations
description: Edit keyed rows immutably by stable clientId while preserving validation and dirty-state identity.
---

A generated reference to `List<Item extends KeyedRow>` provides `form.field(ref).list()`, a `KeyedFormList` editor. Rows carry a stable `clientId`; insertion order and identity are deliberately separate. Row field references address ids, so reorder does not redirect a field handle to a different item.

```dart
final lines = form.field(InvoiceFields.lineItems).list();
lines.append(LineItem.create());
lines.updateById(lineId, (line) => line.copyWith(quantity: 3));
lines.move(0, 2);
lines.removeById(lineId);
```

The editor exposes `items`, `length`, `byId(clientId)`, and `indexOf(clientId)`, plus these immutable operations: `append`, `prepend`, `insert`, `insertAfter`, `removeAt`, `removeById`, `move`, `swap`, `updateAt`, and `updateById`. Indexes are used for intentional positional insert/reorder operations; row lookup and row-scoped fields should use ids. `insertAfter` and `updateById` are no-ops if the id is absent; removal returns `null` if no row was removed. `removeAt` returns `null` out of range.

Each mutation commits through the controller once, triggering the applicable revalidation and notification. When rows are removed, their errors and reveal state are forgotten so an orphaned row error cannot linger. A read-only list scope blocks mutations unless the operation supplies `force: true`; that flag bypasses only the readonly guard.

## Stable row identity and dirty state

`field(ref).dirtyRows()` yields keys of current rows that differ from their original counterparts, matched by `clientId`; new rows are dirty and removed rows are absent from the result. Generated row refs continue to address the same logical item after moves. See the [dynamic lists guide](docs/guides/dynamic-lists) for the working packing-list example and [Flutter lists](docs/flutter/long-lists) for virtualized widgets. Unmounted Flutter rows do not discard controller-owned model state.
