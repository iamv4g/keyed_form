---
title: Refinements and async validation
description: Add conditional custom rules to schema validators and choose the matching synchronous or asynchronous entry point.
---

A refinement adds a predicate after a validator's built-in rules. Scalar and list refinements can return `bool` or `Future<bool>`; object refinements inspect the whole field map. The predicate receives the validated value for its validator family.

```dart
final password = ks.string().min(10).refine(
  (value) => value?.contains('!') ?? false,
  error: .text('Include an exclamation mark'),
  when: (value) => value != null,
  params: {'rule': 'symbol'},
);
```

`when` skips a refinement when its condition is false. `abort: true` stops later refinements after a failed refinement. `params` is carried with the custom issue for message localization. Validators return their first failed built-in rule rather than collecting every scalar failure.

## Object refinements and error targets

Use an object refinement for a relation across fields, such as matching confirmation values. Supply `path` or `key` to attach the issue to a field: `key` overrides `path`. A path may identify a nested field; when neither is supplied, the issue targets the object root. A target must correspond to an actual field for the error to attach usefully.

```dart
final credentials = ks.object({
  'password': ks.string(),
  'confirmation': ks.string(),
}).refine(
  (data) => data['password'] == data['confirmation'],
  error: .text('Passwords do not match'),
  path: 'confirmation',
);
```

For user-facing messages, a rule-specific error takes priority over the validator-level error, followed by the built-in message. `KSError.builder` is resolved lazily; if it returns null, resolution falls through to the next available message. See [errors and localization](docs/schema/errors).

## Choose the validation entry point

Use `validateMap` / `validateValues` for synchronous predicates and `validateMapAsync` / `validateValuesAsync` if a reachable predicate can be asynchronous. Calling synchronous validation when an async predicate is reached throws `KSAsyncValidationError`; it is not treated as a normal invalid value.

Schema-level async predicates are distinct from controller validation. The
controller resolver is synchronous, so do not assign generated
`validateDataAsync` to `resolver` or expect the controller to await it. For
remote availability checks, declare a typed
`KeyedFormAsyncValidator.field` (or nested `.forEach`) rule; see
[Form State async validation](docs/form-state/async-validation).