# keyed_schema

Schema-driven declarative validation and type-safe form definitions for `keyed_lens`. Pure Dart, zero Flutter dependency.

## Features

- **Fluent Schema DSL (`ks.*`):** `ks.object({...})`, `ks.string()`, `ks.int()`, `ks.double()`, `ks.boolean()`, `ks.enums()`, `ks.list()`, `ks.map()`.
- **Identity-First Keyed Optics Integration:** Automatically maps validation errors to `FieldKey` and `FieldErrors` instances.
- **Cross-Field Refinements:** `.refine((data) => ..., error: .text('...'), path: '...', when: ..., abort: ...)` with form-level root error support.
- **Unified Async Validation:** `refine` seamlessly supports `FutureOr<bool>` with `validateMapAsync(...)` and `validateAsync(...)`.
- **Dynamic i18n & Lazy Message Resolution:** Clean Dart 3 dot-shorthand with `error: .text('...')` or `error: .builder((issue) => t.errors...)`.

## Usage

```dart
import 'package:keyed_schema/keyed_schema.dart';

part 'invoice_schema.g.dart';

@keyedSchema
final invoiceSchema = ks.object({
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

Combine with [`keyed_form_gen`](../keyed_form_gen) to automatically generate Immutable Data Classes (`InvoiceSchema`, `LineItemSchema`), keyed optics (`InvoiceFields.lineItem(ref).description`), and validation methods (`InvoiceSchema.validateData(schema)` / `schema.validate()`).
