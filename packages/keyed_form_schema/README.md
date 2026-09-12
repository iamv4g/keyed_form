# keyed_form_schema

Schema-driven declarative validation and type-safe form models for the `keyed_form` family. Pure Dart, zero Flutter dependency. Re-exports `keyed_form_core`.

## Features

- **Fluent Schema DSL (`ks.*`):** `ks.object({...})`, `ks.string()`, `ks.int()`, `ks.double()`, `ks.boolean()`, `ks.enums()`, `ks.list()`, `ks.map()`.
- **Identity-First Field References:** Automatically maps validation errors to `FieldKey` and `FieldErrors` instances.
- **Cross-Field Refinements:** `.refine((data) => ..., error: .text('...'), path: '...', when: ..., abort: ...)` with form-level root error support.
- **Unified Async Validation:** `refine` seamlessly supports `FutureOr<bool>` with `validateMapAsync(...)` and `validateAsync(...)`.
- **Dynamic i18n & Lazy Message Resolution:** Clean Dart 3 dot-shorthand with `error: .text('...')` or `error: .builder((issue) => t.errors...)`.

## Usage

```dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'invoice_schema.kfg.dart';

final _invoiceSchema = ks.object({
  'title': ks.string().min(3, error: .text('Invoice title must be at least 3 characters')),
  'lineItems': ks.list(
    ks.object({
      'description': ks.string().min(1, error: .text('Description is required')),
      'unitPrice': ks.string().optional(),
      'taxCode': ks.int().optional(),
    }),
  ).min(1, error: .text('At least 1 line item required')),
});
```

Combine with [`keyed_form_gen`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_gen) to automatically generate Immutable Data Classes (`InvoiceSchema`, `LineItemSchema`), keyed optics (`InvoiceFields.lineItem(ref).description`), and validation methods (`InvoiceSchema.validateData(schema)` / `schema.validate()`).
