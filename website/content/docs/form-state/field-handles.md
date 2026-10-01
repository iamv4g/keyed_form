---
title: Field handles
description: Use typed field references to read, write, touch, freeze, and inspect fields.
---

`form.field(ref)` returns a `FieldHandle<Root, Value>` whose value type comes from the `FieldRef`. Generated refs are the ordinary entry point; a ref may become unresolved when a containing nullable object, list row, or union variant is absent.

```dart
final email = form.field(InvoiceFields.customerEmail);
email.set('ada@example.com');
email.update((current) => current.trim());
email.touch();
print(email.value);
print(email.error); // null when no error is visible
```

A handle exposes `key`, `value`, `error`, `dirty`, `isReadOnly`, `isValidating`, and `isFailedValidation`. `value` is nullable because the path may not resolve even when the field's declared type is non-null. `error` is visibility-gated; the error can exist in `form.errors` while remaining hidden by the selected mode.

## Writes and touch

`set(value)` replaces the value with a statically checked type. `update(transform)` reads, transforms, and writes in one controller operation. Both no-op when the path no longer resolves or the draft is unchanged; readonly blocks ordinary writes. Writes run validation only when the configured mode or post-submit `reValidateMode` schedules them. `touch()` reports a blur, records interaction, and runs blur validation when the mode requires it.

```dart
final email = form.field(InvoiceFields.customerEmail);
email.set('not an address'); // resolver can record an error
assert(email.error == null); // e.g. still hidden before touch in onTouched
email.touch();
assert(email.error != null);
```

Modes determine automatic validation triggers as well as error visibility; see [Validation and visibility](docs/form-state/validation).

## Read-only fields and subtrees

`markReadOnly()` freezes this key; controller-level `markReadOnly(key)` can freeze an ancestor subtree. Read-only values are still validated. The configuration survives `seed` and `reset`. `force: true` on `set`, `update`, or list mutation bypasses only the write guard; it does not skip immutable updates, validation, or notifications.

```dart
final total = form.field(InvoiceFields.total);
total.markReadOnly();
total.set(100); // ignored
 total.set(100, force: true); // explicit write through the freeze
```

Remove the freeze with `unmarkReadOnly()`. Unmarking a leaf does not cancel a read-only ancestor scope; unmark that scope itself.

## Lists and dirty rows

For generated refs to a `List<Item extends KeyedRow>`, `form.field(listRef).list()` returns the by-id [list editor](docs/form-state/lists). `dirtyRows()` identifies changed current rows against the baseline by `clientId`; newly added rows count as dirty. Removed rows are not yielded. A stale row ref becomes unresolved instead of silently targeting whichever item now occupies the old index.
