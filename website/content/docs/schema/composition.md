---
title: Objects and collections
description: Compose nested object, union, list, map, and enum validators and understand their traversal boundaries.
---

An object schema groups validators under field names, returning errors keyed by `FieldKey` paths. Use the same schema directly for runtime map validation or pair it with the generator for typed models and references.

```dart
final orderSchema = ks.object({
  'status': ks.enums<OrderStatus>(OrderStatus.values),
  'lines': ks.list(ks.object({
    'sku': ks.string(),
    'quantity': ks.int().min(1),
  })),
  'metadata': ks.map(ks.string(), ks.string()),
});
final errors = orderSchema.validateMap(orderMap);
```

`validateMap` accepts a `Map<String, Object?>`; `validateMapAsync` is its asynchronous counterpart. Generated schemas also expose `validateValues` / `validateValuesAsync` for ordered model values. See [refinements and async validation](docs/schema/refinements) for the distinction between those entry points.

## Nested objects and lists

`ks.object` traverses its nested object and discriminated-union list rows, so failures can be associated with row identity rather than a transient index. A row can carry a stable `clientId`; the resulting `FieldKey` path addresses that row as identity survives reorder. This traversal behavior is specifically provided by the object validator.

A standalone `KSList` applies list-level constraints such as `min`, `max`, `nonEmpty`, and whole-list refinement. It does not promise arbitrary recursive scalar-element validation. Do not use it as a substitute for object-tree traversal when field-level nested errors are required.

## Maps and enums

`ks.map(keyValidator, valueValidator)` synchronously checks entries and reports the first key/value failure at the map field. It does not offer map size or refinement rules, per-entry keyed errors, or deep async map validation. For finite symbolic choices, `ks.enums<E>(values)` accepts members of the supplied enum list.

## Paths and scoped validation

Nested errors use `FieldKey` paths, the shared identity type used by generated refs and controller state. A refinement can direct its error to a declared object `path` or `key`; `key` takes precedence. An absent target attaches at the object root. Runtime path composition does not itself generate field references.

When generated model validation is used with a form controller, its `scopeOf` helper chooses a useful subtree for a write. Scoped validation is not a guarantee that cross-field rules are safe to run on partial data; validate the whole model for final submission. See [Schema refinements](docs/schema/refinements), [Form State validation](docs/form-state/validation), and [generated references](docs/schema/code-generation).