---
title: Builders and rules
description: Catalog of the supported Keyed Form schema builders, chain methods, and their runtime behavior.
---

The `ks` namespace creates immutable validators; chain methods return configured validators. The examples below describe runtime validation, separately from the generated model types and defaults discussed under [Presence and defaults](docs/schema/builders#presence-and-defaults) and [code generation](docs/schema/code-generation).

## Strings

`ks.string({error})` returns a string validator. Its supported chain is `optional()`, `nullable()`, `defaultTo(String)`, `min(int, {error})`, `max(int, {error})`, `length(int, {error})`, `nonEmpty({error})`, `email({error})`, `regex(RegExp, {error})`, `numeric({error})`, `time({error})`, and `refine(test, {error, when, abort, params})`. Required strings reject null and trimmed-empty input by default; `min`/`max` then check nonempty values, `length` requires an exact length, and `nonEmpty` is `min(1)`. The format helpers constrain email, regex, numeric-string, or time-string formats.

```dart
ks.string().min(8).regex(RegExp(r'[A-Z]'))
```

`defaultTo` substitutes only when the input is null; it does not rewrite other blank input. Optional and nullable strings skip missing values at runtime.

## Numbers

`ks.int({error})`, `ks.double({error})`, `ks.number({error})`, and alias `ks.num({error})` produce numeric validators. Each supports `optional()`, `nullable()`, `defaultTo(value)`, `min(value, {error})`, `max(value, {error})`, `positive({error})`, `negative({error})`, and `refine(test, {error, when, abort, params})`. `int` accepts integers; `double` accepts doubles; `number`/`num` are general numeric validators. Bounds are inclusive for min/max; positive and negative require strict sign.

```dart
ks.int().min(1).max(10)
```

## Booleans

`ks.boolean({error})` supports `optional()`, `nullable()`, `defaultTo(bool)`, `trueOnly({error})`, and `refine(test, {error, when, abort, params})`. `trueOnly` accepts only `true` among boolean values.

```dart
ks.boolean().trueOnly()
```

## Enums

`ks.enums<E>(List<E> values, {error})` accepts only a member of the supplied enum values. It supports `optional()`, `nullable()`, `defaultTo(E)`, and `refine(test, {error, when, abort, params})`.

```dart
ks.enums<ShippingSpeed>(ShippingSpeed.values).defaultTo(ShippingSpeed.standard)
```

## Lists

`ks.list<E>(itemValidator, {error})` takes an element validator and supports `optional()`, `nullable()`, `defaultTo(List<E>)`, `min(int, {error})`, `max(int, {error})`, `nonEmpty({error})`, and `refine(test, {error, when, abort, params})`. The length rules and refine apply to the list as a whole. Do not assume standalone `KSList` recursively reports arbitrary scalar-element failures; nested object/union row traversal is provided by `KSObject` composition, described in [objects and collections](docs/schema/composition).

```dart
ks.list(ks.string()).nonEmpty()
```

## Maps

`ks.map<K, V>(keyValidator, valueValidator, {error})` validates map keys and values synchronously. It supports `optional()`, `nullable()`, and `defaultTo(Map<K, V>)`. This builder has no `min`, `max`, or `refine` chain. Validation stops at the first failing entry and reports at map level; it does not produce per-entry keyed errors or perform deep async map validation.

```dart
ks.map(ks.string(), ks.int())
```

## Objects

`ks.object(Map<String, KSValidator<Object?>> fields, {className, error})` composes named fields and supports `optional()`, `nullable()`, and `refine(test, {error, when, abort, params, path, key})`. It can be validated as an untyped map with `validateMap` / `validateMapAsync`, or as generated field values with `validateValues` / `validateValuesAsync`; details and nested collection behavior are in [objects and collections](docs/schema/composition). Refinement output and async semantics are covered in [refinements](docs/schema/refinements).

```dart
ks.object({'name': ks.string(), 'age': ks.int().min(0)})
```

## Discriminated unions

`ks.discriminatedUnion<T>(String discriminator, Map<String, KSObject> variants, {className, error})` dispatches to an object schema using a discriminator value. It supports `optional()`, `nullable()`, `validateMap`, and `validateMapAsync`; an unknown discriminator is a validation error. See [discriminated unions](docs/schema/unions) for variant construction and generated types.

```dart
ks.discriminatedUnion('kind', {'note': noteSchema, 'task': taskSchema})
```

## Presence and defaults

There is no `.required()` method: required is the default runtime behavior. For strings, missing/null and trimmed-empty values fail unless `optional()` or `nullable()` allows missing input. Those modifiers are distinct metadata even though both allow null during runtime validation. `defaultTo(value)` substitutes for null before validation, not for every blank string.

Generated types/defaults are decided by the generator's schema analysis, not simply copied from the runtime null policy. For example, the generated login email is a non-null `String` with an initial `''` default, which can still fail its email rule. Numeric fields without an explicit default infer nullable types. An optional boolean alone does not imply `bool?`. Inspect the generated API for your schema; see [naming and types](docs/schema/code-generation#naming-and-types).