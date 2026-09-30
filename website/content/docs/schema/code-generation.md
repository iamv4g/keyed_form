---
title: Code generation
description: Set up keyed_form_gen, generate immutable schema models and field references, and integrate them with form state.
---

The generator reads schema declarations and emits immutable data models, validation methods, and typed field references. It does not generate a form controller or widgets. Keep the schema as the source of truth and regenerate after changing its shape.

## Setup

Add the runtime package and generator tooling to the consumer project:

```sh
dart pub add keyed_form_schema
dart pub add -d keyed_form_gen build_runner
```

Place the file-level annotation on `library;`, declare a matching generated part filename, and use a private top-level schema variable. For example, `invoice_schema.dart` pairs with `invoice_schema.kfg.dart`:

```dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'invoice_schema.kfg.dart';

final _invoiceSchema = ks.object({
  'lineItems': ks.list(ks.object(className: 'LineItemSchema', {
    'description': ks.string().min(1),
    'quantity': ks.int().min(1).defaultTo(1),
    'unitPrice': ks.int().min(0).defaultTo(0),
  })).min(1),
  'total': ks.int().defaultTo(0),
});
```

## Build and watch

Run the builder from the package root. Output is written beside the annotated source file; commit the generated `.kfg.dart` file with the source, and never hand-edit generated output.

```sh
dart run build_runner build -d
dart run build_runner watch -d
```

## Generated output

| Generated API | Purpose |
|---|---|
| Immutable model, `create`, `copyWith`, equality and `toMap` | Construct and update typed drafts; list-row models receive stable `clientId` identity. |
| `InvoiceFields` and nested wrappers/row refs | Address model fields through typed `FieldRef` / `StrictFieldRef` values; row references select by client id. |
| Union base and variant classes | Represent discriminator alternatives with variant-specific fields. |
| `validate`, `validateData`, `validateAsync`, `validateDataAsync` | Run sync or async schema validation against model data. |
| `scopeOf(FieldKey)` | Choose the default subtree scope for a written field. |

A compact generated API looks like this (the emitted row and field-reference shapes are shown in the same form as the checked-in packing schema output):

```dart
final draft = InvoiceSchema.create(
  lineItems: [LineItemSchema.create(description: 'Train fare')],
);
final rowDescription = InvoiceFields.lineItem(
  lineItemClientId: draft.lineItems.single.clientId,
).description;
final errors = InvoiceSchema.validateData(draft);
final invalid = InvoiceSchema.validateData(
  InvoiceSchema.create(lineItems: [LineItemSchema.create(description: '')]),
);
// `errors` is empty; `invalid` contains the required-description issue.
```

Generated row `create()` supplies a `clientId` when one is not provided. Preserve that id when replacing or moving a row so references and keyed errors continue to address the same logical item.

## Integrate with form state

Use the generated synchronous validator as a controller resolver, along with the generated initial model and refs:

```dart
final controller = KeyedFormController<InvoiceSchema>(
  initialValue: InvoiceSchema.create(),
  resolver: InvoiceSchema.validateData,
  scopeOf: InvoiceSchema.scopeOf,
);
final description = InvoiceFields.lineItem(
  lineItemClientId: controller.value.lineItems.first.clientId,
).description;
```

`validateDataAsync` is an async schema-validation entry point, not a valid synchronous controller resolver. The generator does not create controllers or framework bindings; continue to [Form State](docs/form-state) for lifecycle and [Flutter](docs/flutter) for widgets.

## Naming and types

By default, a private schema variable such as `_invoiceSchema` generates `InvoiceSchema`. Set `@KeyedSchema(suffix: 'Model')` to change the default suffix, or pass `className` to an object builder to name that generated object explicitly. The declaration is identified from its schema variable name; private top-level variables are the normal pattern.

Generated nullability/defaults are inferred from the schema expression by the parser and can differ from runtime validation policy. In checked-in output, a required string field such as login email is `String` initialized to `''`; that initial value can still fail the email rule. Numeric fields without an explicit default infer nullable types. An optional boolean alone does not imply `bool?`; nullable metadata does. List fields default to `const []`, and non-null booleans default to `false` in the current generated output. Verify types for the specific declaration rather than treating these examples as a universal runtime rule.

## Function-form schemas

A schema can be declared as a function, but generation reads its static AST/schema shape. Validation can re-invoke a function-form schema; that does not make arbitrary runtime-computed fields or branch-dependent return shapes into a stable generated model. Prefer a statically visible schema expression. For locale-sensitive messages, a lazy `KSError.builder` is sufficient; a function-form declaration is not dynamic-schema support.

## Troubleshooting

- Keep `@keyedSchema` at file scope on `library;`; it is not a per-variable annotation.
- The `part` filename must match the generated destination exactly: `invoice_schema.kfg.dart` beside `invoice_schema.dart`.
- Rerun the build after changing fields, chains, or nested schema structure.
- The parser relies on supported literal schema expressions and statically inspectable object/union shapes. Computed field maps and branch-dependent function returns do not define a reliable generated model shape.
- If an object refinement uses `path`, ensure it names a real field/path in the schema; see [refinement targeting](docs/schema/refinements#object-refinements-and-error-targets).
