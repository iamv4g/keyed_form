---
title: How it works
description: A form is an immutable value, and each field is addressed by a generated typed reference.
---

The controller owns a draft value and validation state independently of widgets. Widgets connect to the fields they display, so scrolling or rebuilding the UI does not discard the draft.

## A field is a typed coordinate

The generator creates `FieldRef<Root, Value>` objects for schema fields. A reference carries the value type and the path needed to read and update that value. Nested references compose from generated members instead of string paths.

```dart
final email = form.field(LoginFields.email);
email.value; // String?
email.set('hello@example.com');
email.error;
```

## References reflect whether a value exists

- `StrictFieldRef<Root, Value>` addresses a root field that always exists.
- `FieldRef<Root, Value>` can stop resolving if a row or nullable object disappears.
- `VariantFieldRef<Sum, Variant>` resolves only while a union contains that variant.

The generator chooses the appropriate reference type. A deleted list row therefore produces an unresolved field instead of a stale write.

## Rows have stable identity

Dynamic rows use `clientId` as identity rather than their current array index. Insertions and reordering change position while field state stays associated with the same row. See [dynamic lists](docs/dynamic-lists).

## Updates are scoped to the field

`KeyedFormField` observes its field reference. When that value changes, the corresponding field widget rebuilds without notifying unrelated fields.
