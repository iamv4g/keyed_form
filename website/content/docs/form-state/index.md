---
title: Form State
description: Manage immutable drafts, typed fields, validation, and collection identity in pure Dart.
---

`keyed_form` is the pure-Dart state layer: a controller owns a typed draft, baseline, keyed errors, and lifecycle state independently of any widget tree. Generated refs make reads and writes address the same stable field identity. Flutter bindings are a separate layer; see [Flutter](docs/flutter).

A minimal generated-model setup looks like this:

```dart
final form = KeyedFormController<InvoiceSchema>(
  initialValue: InvoiceSchema.create(),
  mode: KeyedFormMode.onTouched,
  resolver: (draft, scope) => InvoiceSchema.validateData(draft, scope: scope),
  scopeOf: InvoiceSchema.scopeOf,
);
form.field(InvoiceFields.customerEmail).set('ada@example.com');
```

Generated models and validators are described in [Schema](docs/schema); controller lifecycle and field access begin with [Controller and lifecycle](docs/form-state/controller) and [Field handles](docs/form-state/field-handles). For framework bindings see [Flutter](docs/flutter).

## Explore Form State

- [Controller and lifecycle](docs/form-state/controller): drafts, baseline, reset, submit, disposal, and snapshots.
- [Field handles](docs/form-state/field-handles): typed refs, visibility, readonly state, and writes.
- [Validation and visibility](docs/form-state/validation): resolver scopes and error display modes.
- [Async validation](docs/form-state/async-validation) and [server errors](docs/form-state/server-errors).
- [List operations](docs/form-state/lists) and [relations](docs/form-state/relations).
- [Form State API](docs/form-state/api-reference): compact member index.
