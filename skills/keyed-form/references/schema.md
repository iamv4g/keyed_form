# Schema and codegen

## Contents

- Declaring a schema
- Running codegen
- The `ks.*` namespace
- Cross-field rules
- Error messages
- Rows in a list
- What gets generated, per class
- Discriminated unions
- Validating without generating

## Declaring a schema

```dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'my_form_schema.kfg.dart';

final _myFormSchema = ks.object({ /* ... */ });
```

- `@keyedSchema` sits directly above the bare `library;` directive — it is **file-level**, not attached to the `ks.object(...)` declaration. `@KeyedSchema(suffix: 'Model')` changes the suffix appended to every class name generated from that file (default `'Schema'`).
- `part 'x.kfg.dart';` is required, and the filename must be the schema file's own name with `.dart` replaced by `.kfg.dart`.
- Every top-level `ks.object(...)` / `ks.discriminatedUnion(...)` declaration in an annotated file is picked up — one file may hold several schemas.
- A schema may be a top-level function returning a `KSObject` instead of a `final` variable, for a schema that must be rebuilt at call time — every generated `validate()` then re-invokes that function each call. Prefer a plain `final` (built once) unless you specifically need that.
- Name the schema variable (or function) with a leading underscore, as in `SKILL.md`: `_myFormSchema` generates `MyFormSchema` / `MyFormFields`.

## Running codegen

Add `keyed_form_schema` as a dependency and `build_runner` + `keyed_form_gen` as dev dependencies — no extra build configuration is needed in the consuming project. Then:

```
dart run build_runner build
dart run build_runner watch   # regenerate continuously while editing schemas
```

Commit the generated `.kfg.dart` file next to its schema — it is real, resolvable source, not something to gitignore.

## The `ks.*` namespace

Every constructor and every chained method returns a **new** instance — nothing mutates in place. `ks.string()..min(3)` (a cascade) throws the result of `.min(3)` away; always assign or chain the return value.

| Constructor | Value | Chain |
|---|---|---|
| `ks.object(fields, {className, error})` | `Map<String, Object?>?` | `.optional() .nullable() .refine(test, {error, path, key, when, abort, params})` |
| `ks.string({error})` | `String?` | + `.min(n) .max(n) .length(n) .nonEmpty() .email() .regex(re) .numeric() .time() .refine(test, {error, when, abort, params})` |
| `ks.int({error})` / `ks.double({error})` / `ks.number({error})` (alias `ks.num`) | `int?` / `double?` / `num?` | + `.min(n) .max(n) .positive() .negative() .refine(...)` |
| `ks.boolean({error})` | `bool?` | + `.trueOnly() .refine(...)` |
| `ks.enums<E extends Enum>(E.values, {error})` | `E?` | + `.refine(...)` |
| `ks.list<E>(itemValidator, {error})` | `List<E>?` | + `.min(n) .max(n) .nonEmpty() .refine(test, ...)` — the whole list, not a per-item check |
| `ks.map<K, V>(keyValidator, valueValidator, {error})` | `Map<K, V>?` | no `.min` / `.max` / `.refine` — size or shape rules belong on the parent object |
| `ks.discriminatedUnion<T>(discriminatorKey, {variantName: ks.object(...)}, {className, error})` | one of the variant maps | `.optional() .nullable()` — no `.refine()` at this level |

Common to every validator: `.optional()` and `.nullable()` both bypass the "required" check on `null` input (tracked separately, but with the same effect on that check); `.defaultTo(value)` substitutes `value` for `null` **before** validation runs.

**Gotcha — a required numeric/enum field can still generate as nullable.** `string` and `boolean` fields get an implicit default (`''` / `false`) when required with no `.defaultTo()`, so their generated field stays non-nullable. `int` / `double` / `number` / `enums` have **no implicit default** — without `.defaultTo(...)`, the generated field is nullable even for a field the schema calls required, and only `.validate()` catches a missing value at runtime, not the type system. Pair every required numeric or enum field with `.defaultTo(...)` when a non-nullable generated field is wanted.

## Cross-field rules

Put them on the object, not on an individual field:

```dart
ks.object({...}).refine(
  (data) => (data['checkIn'] as DateTime).isBefore(data['checkOut'] as DateTime),
  error: .text('Check-out must be after check-in'),
  path: 'checkOut',
)
```

`test` receives the whole `Map<String, Object?>` for that object. `path` targets a named field under this object for the error; `key` targets an absolute `FieldKey` and wins over `path` when both are given; with neither, the error lands on the object's own key (a whole-object error). `when` gates whether the refinement runs at all. `abort: true` stops *later* refinements on the same object once this one fails — it never stops per-field validation, which already ran first. `params` carries arbitrary values into the resulting issue, for a message resolved elsewhere to interpolate without re-parsing text.

## Error messages

Every built-in rule has a default English message, so no rule requires an `error:` — except `.refine()`, whose default is the bare `'Invalid'`. Override by attaching a `KSError` at the rule itself, or at the validator's own construction; a rule-level `error:` wins over a validator-level one, which wins over the default message:

```dart
KSError.text('Fixed message')
KSError.builder((issue) => switch (issue) {
  KSTooSmallIssue(:final minimum) => 'Need at least $minimum',
  _ => null, // falls through to the next precedence level
})
```

The issue's **code** (`invalidType` / `tooSmall` / `tooBig` / `invalidFormat` / `invalidValue` / `custom`) is fixed per rule and can't be changed — call `.validateIssue()` / `.validateIssueAsync()` instead of `.validate()` / `.validateAsync()` to get the typed issue and branch on its code rather than its message.

If any `.refine()` anywhere in the schema is async, use `.validateAsync()` / `.validateMapAsync()` everywhere in that call chain — calling the synchronous path when an async refinement needs to run throws an async-validation error.

## Rows in a list

Every item class of `ks.list(ks.object({...}))` (or a list of a discriminated union) is generated with a required `clientId` field first, implementing the row-identity interface every list-item class carries. Only the generated `.create({...})` factory fills `clientId` in automatically when omitted — the plain constructor always requires it explicitly. **Always build new rows with `.create(...)`.** Row identity, for both validation and field references, is `clientId` equality, never index — a field reference built from a `clientId` keeps addressing the same row across inserts, removals, and reorders of its siblings; an index-based identity would silently point at the wrong row instead.

## What gets generated, per class

For `final _tourSchema = ks.object({...})` (class name inferred from the variable, leading underscore stripped — `_fooSchema` → `FooSchema`; give an explicit `className:` for anything whose name doesn't derive cleanly):

- `class TourSchema` — one field per schema key, a callable `copyWith`, `toMap()`, `operator ==` / `hashCode`.
- `factory TourSchema.create({...})` — every parameter optional, resolving to the field's own default (and `clientId` to a fresh id, for a row class) when omitted. Prefer this over the plain constructor whenever anything has a default.
- `TourSchema.validate([FieldKey? scope])` / `.validateAsync([scope])` — validates this value.
- `static TourSchema.validateData(TourSchema value, [scope])` / `.validateDataAsync(...)` — the same, in exactly the `(value, scope) -> FieldErrors<String>` shape `KeyedFormController`'s `resolver` expects; pass it directly, no wrapper closure needed.
- `static TourSchema.scopeOf(FieldKey writtenKey)` — the matching `KeyedFormController.scopeOf`: narrows a written key down to the row it's inside (for a by-id list) or the top-level field it belongs to.
- `abstract final class TourFields` — `static StrictFieldRef<TourSchema, FieldType> get <field>` for every scalar field.

**Only the root schema's generated class has `validate()` / `validateData()` / `scopeOf`.** A class discovered as a nested object or list item (not itself a named top-level schema) has none of these — always validate from the root; it recurses into every nested field and row internally.

For a list-of-objects field (`'hotels': ks.list(ks.object(className: 'HotelSchema', {...}))`), `TourFields` additionally gets:

```dart
typedef HotelRef = ({String hotel});
static HotelFieldRefs hotel(HotelRef at) =>
    HotelFieldRefs(hotels.at(at.hotel, (x) => x.clientId == at.hotel));
```

and a `HotelFieldRefs` class exposing each of that row's fields as a field reference reachable straight from the root — `TourFields.hotel((hotel: someClientId)).hotelName`. Reading or writing through one for a row that's since been removed is a safe no-op (a read returns `null`, a write does nothing), never an error. A list nested inside another by-id row generates the same shape one level deeper, threading the outer row's id through its own ref record.

A plain (non-list) nested object field is exposed the same way, minus the by-id step — as a getter rather than a method taking a row identifier.

## Discriminated unions

```dart
ks.discriminatedUnion('kind', {
  'a': ks.object({...}),
  'b': ks.object({...}),
}, className: 'SectionSchema')
```

generates a sealed base class plus one subclass per variant key. A field with the same name and shape in **every** variant is promoted onto the shared base class; a field unique to one variant stays only on that variant's own class — keep a shared field's type and rules identical across every variant, since the base class is typed from whichever variant is found first. When reached through a field-references wrapper, each variant is exposed as a narrowing getter — `someRef.asA` / `.asB` — that resolves only while the value actually is that variant; reading or writing through the wrong one is a safe no-op, the same affine behavior as a removed row.

Pass the discriminator key as a string literal, never a variable — anything else silently falls back to a default discriminator name instead of failing.

## Validating without generating

`ks.object({...})` is a plain runtime value on its own — `.validateMap(rawMap)` / `.validateMapAsync(...)` works with no `@keyedSchema`, no `part`, no build step, returning the same `FieldErrors<String>` keyed by `FieldKey`. Reach for this to validate a payload with no reason to generate a typed class for it (an incoming API response, a one-off check); add `@keyedSchema` and `part` to the same file later with no schema rewrite if a generated class and field references turn out to be wanted too.
