# keyed_form_gen

Code generator for [`keyed_form_schema`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_schema) schemas.

Automatically translates declarative `ks.object({...})` schemas into **Immutable Data Models**, **field-name keyed references** (`Fields` navigators + `FieldRefs` wrappers), and **type-safe validation functions**.

---

## Features

From a single declarative schema declaration, `keyed_form_gen` generates:

1. **Immutable Data Classes (`*Schema`, `*Model`):**
   - Pure Dart immutable classes with `const` constructors and default values.
   - Automatically injects `clientId` (UUID v4) for all elements inside `ks.list(...)`.
   - Factory `.create()` method with auto-generated UUIDs.
   - `copyWith()`, value equality `operator ==`, and `hashCode`.

2. **Keyed field references (`keyed_form_core`):**
   - A `<Root>Fields` namespace class (e.g. `InvoiceFields`, `LineItemBuilderFields`)
     with a `static` navigator **per schema field**: `InvoiceFields.lineItem(ref)`
     for `'lineItems'`, `InvoiceFields.attachment(ref)` for `'attachments'`.
   - Each navigator returns a `<Field>FieldRefs` wrapper — a `FieldRef` to
     that node that also exposes one leaf `FieldRef` getter per field, so
     you write `InvoiceFields.lineItem(ref).description`.
   - Row identity is a plain `String` clientId. A navigator takes a
     `<Field>Ref` record of id strings:
     `typedef LineItemRef = ({String invoice, String lineItem});`. No `ClientId`
     extension types.
   - Discriminated unions are wrapped too: `paymentMethod(ref)` exposes the common
     fields plus `.asCash` / `.asCard` narrowers —
     `paymentMethod(ref).asCard.card.note`.
   - Non-list nested objects get a wrapper reached by a getter:
     `InvoiceInfoBuilderFields.info.name`.

3. **Synchronous & Asynchronous Validation methods:**
   - `<Name>.validate()` / `<Name>.validateAsync()` on the data class.
   - `<Name>.validateData(schema)` / `<Name>.validateDataAsync(schema)` statics
     — exactly the `(value, scope) -> FieldErrors<String>` shape a form
     controller's resolver expects, so it can be passed directly.
   - Errors map directly to `FieldKey` and `FieldErrors<String>`.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  keyed_form_schema: ^0.1.0

dev_dependencies:
  build_runner: ^2.15.0
  keyed_form_gen: ^0.1.0
```

---

## Usage

### 1. Declare Schema

`@keyedSchema` is a **file-level** annotation: it goes on the `library`
directive, and the generator picks up every schema declared in that file —
whether a top-level variable or a top-level function (e.g. for dynamic i18n).

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

The schema variable is named with a leading underscore — app code addresses
the generated class and its `Fields` class, never the schema variable
itself, so keeping it private avoids adding a public name to the library's
top level for no reason.

### 2. Run Code Generation

```bash
dart run build_runner build
```

### 3. Use Generated Code

The generator produces (for the schema above):
- `class InvoiceSchema` & `class LineItemSchema`
- `typedef LineItemRef = ({String lineItem});`
- `abstract final class InvoiceFields` with `InvoiceFields.title`, `InvoiceFields.lineItem(ref)`
- `final class LineItemFieldRefs` — the wrapper `lineItem(ref)` returns
- `InvoiceSchema.validateData(schema)` / `schema.validate()`

```dart
// 1. Create instances with auto clientId
final lineItem1 = LineItemSchema.create(description: 'Consulting services');
final invoice = InvoiceSchema.create(
  title: 'Q1 Services Invoice',
  lineItems: [lineItem1],
);

// 2. Read / write one field immutably, without rebuilding the aggregate.
//    The ref is a plain record of clientId strings.
final ref = (lineItem: lineItem1.clientId);
final updatedInvoice = InvoiceFields.lineItem(ref).description
    .set(invoice, 'Consulting services (revised)');

// `lineItem(ref)` itself is a lens to the whole row:
final row = InvoiceFields.lineItem(ref).getOrNull(updatedInvoice);

// 3. Validate
final errors = InvoiceSchema.validateData(updatedInvoice);
if (errors.isNotEmpty) {
  print(errors.byKey(InvoiceFields.lineItem(ref).description.key));
}
```

---

## Suffix & Naming Configuration

### Default Suffix (`Schema`)
By default, `@keyedSchema` appends the `Schema` suffix to all generated classes;
the `<Root>Fields` namespace drops it (`InvoiceSchema` → `InvoiceFields`). The
generator strips a leading underscore first, so a private schema variable
generates the identical class names:
- `_invoiceSchema` $\rightarrow$ **`InvoiceSchema`** / **`InvoiceFields`**
- `'lineItems'` $\rightarrow$ **`LineItemSchema`** (with `LineItemRef`, `LineItemFieldRefs`, `InvoiceFields.lineItem(ref)`)
- `'itinerary'` $\rightarrow$ **`ItinerarySchema`** (with `ItineraryRef`, `ItineraryFieldRefs`)

### Custom Suffix (`Model`, `Entity`, `Dto`)
You can configure a custom suffix for your project's architectural convention using `@KeyedSchema(suffix: '...')` on the library directive:

```dart
@KeyedSchema(suffix: 'Model')
library;

// ...

final _invoiceSchema = ks.object({
  'lineItems': ks.list(
    ks.object({
      'description': ks.string(),
    }),
  ),
});
```
This generates:
- `InvoiceModel` & `LineItemModel`
- `LineItemRef` & `InvoiceFields.lineItem(ref)`

### Explicit `className`
You can also supply `className` directly in `ks.object(className: ...)`:

```dart
ks.object(className: 'CustomLineItem', {
  'description': ks.string(),
})
```
- If the name already ends with the configured suffix (e.g. `LineItemSchema`), it is kept as-is.
- If not (e.g. `CustomLineItem`), the generator automatically appends the suffix $\rightarrow$ `CustomLineItemSchema`.

---

## Dynamic i18n & Lazy Message Resolution

`KSError.builder((issue) => ...)` resolves the message at the point a rule
actually fails, not when the schema is built — return the current locale's
string from inside the closure and the message tracks whatever the active
locale is at validation time. It works the same whether the schema is a
plain `final` variable or a function:

```dart
@keyedSchema
library;

// ...

final _loginSchema = ks.object({
  'username': ks.string(error: .builder((_) => t.errors.auth.username)),
  'password': ks.string(error: .builder((_) => t.errors.auth.password)),
  'remember': ks.boolean().defaultTo(false),
});
```

Reach for the function form instead — `KSObject _loginSchema() { return ks.object({...}); }` — only when the schema's own *structure* (which fields exist, which rules apply), not just a message string, needs to be rebuilt on every call; every generated `validate()`/`validateAsync()` then re-invokes that function.
