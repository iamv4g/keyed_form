---
title: Field handles
description: Read and update typed fields with generated references and FieldHandle.
---

Pass a generated reference to `form.field(ref)` to get a handle for reading, writing, validation state, and dirty tracking.

```dart
final email = form.field(LoginFields.email);
email.set('alice@example.com');
email.update((value) => value?.trim());
email.touch();
print(email.value);
print(email.error);
print(email.dirty);
```

## Field operations

| Member | Purpose |
|---|---|
| `value` | Current typed value; it can be absent when a nested row no longer exists. |
| `set(value)` | Replace the field value with a compile-time checked type. |
| `update(transform)` | Read, transform, and write as one operation. |
| `touch()` | Mark the field as visited so its error can become visible. |
| `error` | Current validation error, when the display mode allows it. |
| `dirty` | Whether this field differs from its seeded baseline. |
| `markReadOnly()` | Prevent edits through this field. Use `unmarkReadOnly()` to resume editing. |

Each `KeyedFormField` observes its own reference, so updating a field does not rebuild unrelated field widgets. For list rows, references retain the row identity across reordering; see [dynamic lists](docs/dynamic-lists).
