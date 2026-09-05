# keyed_form_gen

Code generator for [`keyed_schema`](../keyed_schema) schemas.

Automatically translates declarative `ks.object({...})` schemas into **Immutable Data Models**, **field-name keyed optics** (`Fields` navigators + `FieldRefs` wrappers), and **type-safe validation functions**.

---

## Features

From a single declarative schema declaration, `keyed_form_gen` generates:

1. **Immutable Data Classes (`*Schema`, `*Model`):**
   - Pure Dart immutable classes with `const` constructors and default values.
   - Automatically injects `clientId` (UUID v4) for all elements inside `ks.list(...)`.
   - Factory `.create()` method with auto-generated UUIDs.
   - `copyWith()`, value equality `operator ==`, and `hashCode`.

2. **Keyed Optics (`keyed_lens`):**
   - A `<Root>Fields` namespace class (e.g. `InvoiceFields`, `LineItemBuilderFields`)
     with a `static` navigator **per schema field**: `InvoiceFields.lineItem(ref)`
     for `'lineItems'`, `InvoiceFields.attachment(ref)` for `'attachments'`.
   - Each navigator returns a `<Field>FieldRefs` wrapper — an `AffineLens` to
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
     (handy for Riverpod / callbacks).
   - Errors map directly to `FieldKey` and `FieldErrors<String>`.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  keyed_lens: ^0.1.0
  keyed_schema: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  keyed_form_gen: ^0.1.0
```

---

## Usage

### 1. Declare Schema

You can declare schemas as top-level variables or top-level functions (e.g. for dynamic i18n):

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

### 2. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
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
the `<Root>Fields` namespace drops it (`InvoiceSchema` → `InvoiceFields`):
- `invoiceSchema` $\rightarrow$ **`InvoiceSchema`** / **`InvoiceFields`**
- `'lineItems'` $\rightarrow$ **`LineItemSchema`** (with `LineItemRef`, `LineItemFieldRefs`, `InvoiceFields.lineItem(ref)`)
- `'itinerary'` $\rightarrow$ **`ItinerarySchema`** (with `ItineraryRef`, `ItineraryFieldRefs`)

### Custom Suffix (`Model`, `Entity`, `Dto`)
You can configure a custom suffix for your project's architectural convention using `@KeyedSchema(suffix: '...')`:

```dart
@KeyedSchema(suffix: 'Model')
final invoiceSchema = ks.object({
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

## Function Schema (Dynamic i18n & Lazy Message Resolution)

For dynamic translation resolution with packages like `slang`:

```dart
@keyedSchema
KSObject loginSchema() {
  return ks.object({
    'username': ks.string().required(t.errors.auth.username),
    'password': ks.string().required(t.errors.auth.password),
    'remember': ks.boolean().defaultTo(false),
  });
}
```
Or with lazy callbacks in variable schemas:
```dart
@keyedSchema
final loginSchema = ks.object({
  'username': ks.string().required(() => t.errors.auth.username),
});
```
