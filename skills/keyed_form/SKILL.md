---
name: keyed_form
description: Build Flutter forms with the keyed_form library — KeyedFormController, the keyed_form_schema `ks.*` schema/validation DSL, keyed_form_gen codegen (@keyedSchema), and keyed_form_flutter widgets (KeyedForm, KeyedFormField, KeyedFieldList). Use whenever the user defines a form's data shape, adds or edits fields or validation rules (sync, async, or cross-field), builds a dynamic list of rows, freezes a field, derives one field from another, wires submit or scroll-to-first-error, or works in a project that depends on keyed_form / keyed_form_schema / keyed_form_flutter — even if they never say the word "form".
---

# keyed_form

A typed form library for Flutter. The state of an entire form is **one immutable value** (the *draft*), owned by **one controller** (`KeyedFormController<Root>`) — fields are not separate controller objects, they are addressed inside that single draft by a `FieldRef<Root, V>` generated from a schema. Declare the shape and validation rules once as a schema, generate the data class and field references from it, then build the controller and widgets against those generated names.

Six packages, bottom to top:

```
keyed_lens              (pure Dart) — the FieldKey / lens primitives everything below builds on
 └── keyed_form_core     — shared vocabulary: FieldRef / StrictFieldRef / VariantRef, FieldErrors, @keyedSchema
       ├── keyed_form_schema   — the `ks.*` schema / validation DSL
       │     └── keyed_form_gen   — dev-time codegen: schema → data class + field references + validators
       └── keyed_form      — the pure-Dart form controller (KeyedFormController)
             └── keyed_form_flutter   — the Flutter widgets
```

An app writes against three of these directly: `keyed_form_schema` (declare the shape), `keyed_form` (the controller — only needed as a direct import outside Flutter), and `keyed_form_flutter` (widgets — its barrel re-exports `keyed_form` and `keyed_form_core`, so a Flutter app needs exactly one import: `package:keyed_form_flutter/keyed_form_flutter.dart`). `keyed_form_gen` runs only at build time and is never imported by app code.

## Quick start

```dart
// signup_schema.dart
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'signup_schema.kfg.dart';

final _signupSchema = ks.object({
  'email': ks.string(error: .text('Email is required'))
      .email(error: .text('Enter a valid email')),
  'password': ks.string(error: .text('Password is required'))
      .min(8, error: .text('At least 8 characters')),
});
```

The schema variable itself is given a **private** (leading-underscore) name — app code never needs it directly, only the generated class and fields below, so keeping it private avoids adding a public name to the library's top level for no reason. The generator strips a leading underscore before deriving the class name, so `_signupSchema` and `signupSchema` generate the exact same `SignupSchema` / `SignupFields` — this is a namespace-hygiene choice, not a behavioral one. Prefer the private form for every schema variable and function-form schema alike.

Run `dart run build_runner build` (or `watch` while editing). This writes `signup_schema.kfg.dart` next to the schema file — commit it, it is real source, not a build artifact. It defines:

- `class SignupSchema` — `email`, `password`, `copyWith`, `toMap()`, `==`/`hashCode`, `.create({...})`, `.validate([scope])`, `static .validateData(...)`, `static .scopeOf(...)`.
- `abstract final class SignupFields` — `static StrictFieldRef<SignupSchema, String> get email` and `.password`.

```dart
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

final form = KeyedFormController<SignupSchema>(
  initialValue: SignupSchema.create(),
  mode: KeyedFormMode.onTouched,
  resolver: SignupSchema.validateData,
);

// build():
KeyedForm<SignupSchema>(
  controller: form,
  child: Column(
    children: [
      KeyedFormField.text<SignupSchema>(
        field: SignupFields.email,
        builder: (context, state, controller) => Focus(
          canRequestFocus: false,
          onFocusChange: (hasFocus) {
            if (!hasFocus) state.onBlur();
          },
          child: TextField(
            controller: controller,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: state.errorText,
            ),
          ),
        ),
      ),
      KeyedFormField.text<SignupSchema>(
        field: SignupFields.password,
        builder: (context, state, controller) => Focus(
          canRequestFocus: false,
          onFocusChange: (hasFocus) {
            if (!hasFocus) state.onBlur();
          },
          child: TextField(
            controller: controller,
            obscureText: true,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: state.errorText,
            ),
          ),
        ),
      ),
      // A submit button needs a context from *inside* the tree KeyedForm
      // builds (see "KeyedForm and context" below) — Builder is the cheapest
      // way to get one when nothing else in the subtree already provides it.
      // If the button also needs to react to submitting (disable it, show a
      // spinner), reach for KeyedFormSelector<SignupSchema, bool> instead —
      // its own builder already hands you a valid context, so no separate
      // Builder is needed then; see "Reading a slice without a full field
      // binding" below.
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => form.handleSubmit(context, (value) async {
            // value.email, value.password — already validated.
          }),
          child: const Text('Sign up'),
        ),
      ),
    ],
  ),
)

// dispose():
form.dispose();
```

The default mode is `onSubmit`: initial values and `seed`/`reset` do not
validate automatically. `onTouched` validates at first actual blur and after
later writes to that field. Report focus loss through `Focus.onFocusChange`;
`onTapOutside` should only unfocus and Enter is not blur. Submit always
validates a fresh draft and reveals the result.

## Two rules that prevent most bugs

- **Always write through `form.field(ref)`** — `.set(value)`, `.update(fn)`, `.list()` — never call `form.setField` / `updateField` / `list` / `mutateList` directly. Those four are marked internal-only on purpose: a `FieldRef<Root, V>` is covariant in `V`, so calling them directly lets the type checker silently widen `V` to a common supertype of the field and whatever value you pass — the call compiles and only fails with a `TypeError` at runtime. `form.field(ref)` pins `V` from `ref` alone, so a wrongly-typed value is rejected at compile time instead.
- **Bind every text field with `KeyedFormField.text`**, never a hand-rolled `TextEditingController` + `onChanged`. It keeps the text controller in sync by watching the controller itself, which is how it tells the user's own typing apart from an external overwrite (a server patch, a sibling field's derived write). Also wiring the wrapped `TextField`'s own `onChanged` into the form, or resetting `.text` by hand on every build, reintroduces caret jumps and breaks composed input (accented characters, CJK input methods) on every keystroke.

## Schema + codegen

### Declaring a schema

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
- **Name the schema variable (or function) with a leading underscore.** App code addresses the generated class and its `Fields` class, never the schema variable itself, so making it private keeps it out of the library's public surface. The generator strips a leading underscore before deriving the class name, so `_myFormSchema` and `myFormSchema` generate the identical `MyFormSchema` / `MyFormFields` — purely a namespace-hygiene choice, with no effect on what gets generated.

### Running codegen

Add `keyed_form_schema` as a dependency and `build_runner` + `keyed_form_gen` as dev dependencies — no extra build configuration is needed in the consuming project. Then:

```
dart run build_runner build
dart run build_runner watch   # regenerate continuously while editing schemas
```

Commit the generated `.kfg.dart` file next to its schema — it is real, resolvable source, not something to gitignore.

### The `ks.*` namespace

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

### Cross-field rules

Put them on the object, not on an individual field:

```dart
ks.object({...}).refine(
  (data) => (data['checkIn'] as DateTime).isBefore(data['checkOut'] as DateTime),
  error: .text('Check-out must be after check-in'),
  path: 'checkOut',
)
```

`test` receives the whole `Map<String, Object?>` for that object. `path` targets a named field under this object for the error; `key` targets an absolute `FieldKey` and wins over `path` when both are given; with neither, the error lands on the object's own key (a whole-object error). `when` gates whether the refinement runs at all. `abort: true` stops *later* refinements on the same object once this one fails — it never stops per-field validation, which already ran first. `params` carries arbitrary values into the resulting issue, for a message resolved elsewhere to interpolate without re-parsing text.

### Error messages

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

### Rows in a list

Every item class of `ks.list(ks.object({...}))` (or a list of a discriminated union) is generated with a required `clientId` field first, implementing the row-identity interface every list-item class carries. Only the generated `.create({...})` factory fills `clientId` in automatically when omitted — the plain constructor always requires it explicitly. **Always build new rows with `.create(...)`.** Row identity, for both validation and field references, is `clientId` equality, never index — a field reference built from a `clientId` keeps addressing the same row across inserts, removals, and reorders of its siblings; an index-based identity would silently point at the wrong row instead.

### What gets generated, per class

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

### Discriminated unions

```dart
ks.discriminatedUnion('kind', {
  'a': ks.object({...}),
  'b': ks.object({...}),
}, className: 'SectionSchema')
```

generates a sealed base class plus one subclass per variant key. A field with the same name and shape in **every** variant is promoted onto the shared base class; a field unique to one variant stays only on that variant's own class — keep a shared field's type and rules identical across every variant, since the base class is typed from whichever variant is found first. When reached through a field-references wrapper, each variant is exposed as a narrowing getter — `someRef.asA` / `.asB` — that resolves only while the value actually is that variant; reading or writing through the wrong one is a safe no-op, the same affine behavior as a removed row.

Pass the discriminator key as a string literal, never a variable — anything else silently falls back to a default discriminator name instead of failing.

### Validating without generating

`ks.object({...})` is a plain runtime value on its own — `.validateMap(rawMap)` / `.validateMapAsync(...)` works with no `@keyedSchema`, no `part`, no build step, returning the same `FieldErrors<String>` keyed by `FieldKey`. Reach for this to validate a payload with no reason to generate a typed class for it (an incoming API response, a one-off check); add `@keyedSchema` and `part` to the same file later with no schema rewrite if a generated class and field references turn out to be wanted too.

`KeyedFormController<Root>` takes:

```dart
KeyedFormController<Root>({
  required Root initialValue,
  required KeyedFormResolver<Root> resolver,
  KeyedFormMode mode = KeyedFormMode.onSubmit,
  KeyedFormReValidateMode reValidateMode = KeyedFormReValidateMode.onChange,
  List<KeyedFormAsyncValidator<Root>> asyncValidators = const [],
  KeyedFormAsyncFailureMode asyncValidationFailureMode =
      KeyedFormAsyncFailureMode.blockSubmit,
  KeyedFormScopeOf? scopeOf,
})
```

The controller owns one immutable draft, its baseline, validation error
sources, interaction/reveal state, and async lifecycle. A generated
`SomeSchema.validateData` is the common synchronous resolver.

### Validation triggers

`KeyedFormMode` schedules validation, not just error visibility:

| Mode | Before the first submit |
|---|---|
| `onSubmit` | No automatic validation |
| `onChange` | Validate after writes |
| `onBlur` | Validate on blur |
| `onTouched` | Validate on first blur, then after writes to that field |
| `all` | Validate after writes and blur |

Initial values, `seed`, and `reset` do not eagerly validate. After a submit
attempt settles, `reValidateMode` selects automatic revalidation (`onChange`
by default; `onBlur` or `onSubmit` are the alternatives). `all` continues to
validate both writes and blur. `touch()` reports blur: it records interaction
and runs the blur trigger when configured.

For text controls, call `state.onBlur()` from actual focus loss, for example
with `Focus.onFocusChange`. `onTapOutside` should only unfocus; it does not
cover keyboard focus traversal. Non-text controls can report blur when their
interaction commits or closes.

### Scoped validation

Without `scopeOf`, an automatic write validates the whole draft. With
`scopeOf`, the resolver validates the mapped subtree; returning `null` skips
automatic validation for that event. Out-of-scope resolver keys trip a debug
assertion. `validate()` and `submit()` always validate the full draft;
`validateScopes()` explicitly validates the requested subtrees whether or not
`scopeOf` is configured.

### Reading and writing one field

```dart
FieldHandle<Root, V> field<V>(FieldRef<Root, V> ref)
```

provides `.value` (`V?`, null if the path no longer resolves), visible `.error`,
`.dirty`, `.isValidating`, `.isFailedValidation`, `.isReadOnly`, plus:

```dart
void set(V value, {bool force = false});
void update(V Function(V current) transform, {bool force = false});
void touch();
Future<KeyedFormValidationResult> validate();
```

`FieldHandle.validate()` reruns configured async rules for the field; it does
not accept an ad-hoc callback. For list fields, `.list()` gives the by-id row
editor (`append`, `insert`, `removeById`, `move`, `updateById`, and others).
`form.errors` is the full merged error map; field `.error` is
visibility-gated.

### Declarative async validation

Async checks are typed rules attached to `asyncValidators`, not work started
from a widget callback:

```dart
asyncValidators: [
  .field(
    field: SignupFields.email,
    validate: (draft, email) => checkEmailAvailability(email),
    timeout: const Duration(seconds: 5),
    onFailure: (error, stack) => reportCheckFailure(error),
  ),
],
```

`validate()` / `validateScopes()` await applicable rules and return a
`KeyedFormValidationResult` with `status`, `errors`, and `failures`:

| Status | Meaning |
|---|---|
| `valid` | No value errors or technical failures (`isValid == true`) |
| `invalid` | At least one value error |
| `unavailable` | At least one technical failure; `isValid` is false even if submit is allowed |
| `superseded` | A newer run or draft change made this result stale |

`onValid` is called only for `valid`. With a value error, `onInvalid` wins;
only when there are no value errors do blocking technical failures route to
`onValidationUnavailable`.
Independent checks start in parallel. Sync value errors gate only async rules
at or below that field scope; an unrelated sibling error does not. Inside
`.forEach(collection: ..., rules: [...])`, nested `.field` callbacks receive
the typed local row draft, and the controller builds concrete keys from each
row's stable `clientId`. Missing paths or inactive union variants skip the
rule; a present nullable value is still passed as its declared nullable type.
Duplicate concrete rules are configuration errors.

A returned message is an async value error; `null` clears only that rule's
previous async message. Per-key display precedence is sync, then server, then
async. Thrown checks and timeouts are technical failures, stored separately
from `errors` with their stack trace and effective `failureMode`.
`onFailure` observes a still-current failure; observer exceptions propagate
after validation state is settled.

Technical failures block submit by default. Override a rule with
`failureMode: KeyedFormAsyncFailureMode.allowSubmit` only when continuing
without a service verdict is safe; the backend may still reject the value.
An explicit result remains `unavailable` (`isValid == false`) if any
technical failure occurred, even if submit is allowed to proceed.

There is **no automatic debounce, cache, or retry**. `onChange` starts
validation for each scheduled write. Prefer `onBlur`/`onTouched` for expensive
remote checks or debounce at the service/request layer. Superseded results
cannot update state or authorize submit, but the underlying network request is
not canceled.

### Validating and submitting

- `await form.validate()` — full fresh validation; reveals its result but does
  not mark the form submitted.
- `await form.validateScopes(scopes)` — returns a structured result scoped to
  the requested subtrees; check `result.isValid` or `result.errors` /
  `result.failures`, not a list of failing keys.
- `form.reveal(scopes)` — changes visibility without running validation.
- `await form.submit(onValid, {onInvalid, onValidationUnavailable})` — starts
  fresh validation, then calls exactly one outcome callback. Value errors
  route to `onInvalid`; blocking technical failures route to
  `onValidationUnavailable`; only an allowed, otherwise error-free result
  calls `onValid`. `submitting` covers validation and callback work.
- A write, reset, seed, or dispose during submit fences the captured draft
  from saving. Concurrent submit attempts do not double-run.
- `form.seed(value, {force})` re-baselines draft and dirty baseline; it is a
  no-op while dirty unless forced. `form.reset()` restores the baseline.
- `setServerErrors` / `setServerErrorPaths` merge and reveal backend value
  errors; malformed wire paths throw.

### Read-only fields

`form.markReadOnly(key)` / `.unmarkReadOnly(key)` / `.isReadOnly(key)` (or the typed `form.field(ref).markReadOnly()` / `.unmarkReadOnly()` / `.isReadOnly`) freeze a field against `.set` / `.update` / list mutation, without touching validation — a frozen field still validates normally. Freezing covers every field nested under the given key too, so freezing a whole row or section needs one call at that key, not one per leaf. `unmarkReadOnly` on a leaf does not undo a freeze placed on one of its ancestors — unmark the ancestor's own key instead. Pass `force: true` to a write to bypass the freeze for that one call only.

Read-only status is configuration, not draft state: it is the one piece of bookkeeping that **survives** `seed()` / `reset()` — touched, revealed, validating, and failed all clear, read-only does not.

### Deriving one field from another

```dart
VoidCallback addRelation<S, D>(
  FieldRef<Root, S> source,
  D Function(S value) select,
  void Function(D value) onChange,
)
```

Calls `onChange` with the selected slice of `source` whenever it actually changes (compared with `==`) — registering it does not itself call `onChange`, since it primes its own baseline from the current value first, and only a later change fires it. It skips silently while `source` doesn't currently resolve (a removed row) rather than treating the gap as a change. It returns a callback that unsubscribes — call it wherever the controller itself is disposed; nothing here is tracked or cleaned up automatically.

## Flutter widgets

### `KeyedForm` and context

`KeyedForm<Root>({required controller, translateError, required child})` publishes the controller down the tree. Read it back with `KeyedForm.controllerOf<Root>(context)` / `.registryOf<Root>(context)` / `.translateErrorOf<Root>(context)` — **`context` must come from somewhere inside the subtree `KeyedForm` builds, never the `build(BuildContext context)` parameter of the widget that constructs `KeyedForm` itself.** That outer context sits *above* `KeyedForm` in the tree, so an ancestor lookup from it fails. Use the context a builder callback hands you instead — a `Builder`'s, a `KeyedFormField`'s, a `KeyedFormSelector`'s, a `KeyedFormBuilder`'s. `translateError` (`String Function(BuildContext, String)`) is read once, non-reactively — give it a stable top-level or static function, not a fresh closure every build.

### Binding one field

```dart
KeyedFormField<Root, V>({required FieldRef<Root, V> field, required builder, bool anchor = true})
KeyedFormField.text<Root>({required FieldRef<Root, String> field, bool anchor = true, required builder})
```

`builder` receives a `KeyedFieldState<V>`: `value`, `onChanged`, `onBlur`, `errorText` (already mode-gated and translated), `fieldKey`, `isValidating`, `isFailedValidation`, `isReadOnly`. It rebuilds only when one of those six actually changes — a write to any other field is a no-op for this widget. `.text` additionally hands the builder a ready `TextEditingController` kept in caret/IME-safe sync with the field; never wire that control's own `onChanged` alongside it — user edits are told apart from external writes solely by watching that controller, and a second `onChanged` reintroduces the exact problems the binding exists to avoid.

Render `enabled: !state.isReadOnly` (or the equivalent) on the wrapped widget to grey out a frozen field — `onChanged` / `state.onChanged` stays safe to wire unconditionally, since a write to a frozen field is already a no-op at the controller.

Pass `anchor: false` for a field that should never be the scroll target for the first error (a checkbox, a switch) — otherwise every `KeyedFormField` registers itself as one automatically.

### Binding a dynamic list of rows

```dart
KeyedFieldList<Root, Item extends KeyedRow>({
  required FieldRef<Root, List<Item>> field,
  required Widget Function(BuildContext, List<Item> items, KeyedFormList<Root, Item> list) builder,
})
```

rebuilds only when the row *set* (its ids, in order) changes — adding, removing, or reordering a row — never for an edit to a value inside one row; give each row's own subtree a `ValueKey` on its `clientId` so its nested `KeyedFormField`s stay stable across that rebuild. `list` is the same row editor `form.field(field).list()` returns.

When something outside the list also needs the live row-id sequence for its own purpose (driving a key per row for scroll offsets, say), track it by hand with the same "compare the id list in order, rebuild only on a real change" approach instead, reading rows straight off `form.field(field).list()`.

### Reading a slice without a full field binding

```dart
Root context.watchForm<Root>();
V? context.watchField<Root, V>(FieldRef<Root, V> ref);
T context.selectForm<Root, T>(T Function(KeyedFormController<Root> form) selector, {bool Function(T, T)? equals});
KeyedFormSelector<Root, T>({required selector, required builder, equals, child});
KeyedFormBuilder<Root>({required Widget Function(BuildContext, KeyedFormController<Root>) builder});
```

`watchForm` / `watchField` / `selectForm` must be called inside `build()`, and the selector or predicate passed to them must be pure — no writes, and no nested call to any of the three from inside one. `selectForm` rebuilds its caller only when the selected value actually changes by `equals` (default `==`); give an explicit `equals` for a collection slice. `KeyedFormSelector` is the same mechanism scoped to a small subtree with an un-rebuilt `child`, useful when the enclosing `build()` is itself expensive — and, since its own `builder` already hands you a context from inside the tree `KeyedForm` builds, it also doubles as the natural place to put a submit button that needs to react to `submitting` (disable it, swap in a spinner) without a separate `Builder`:

```dart
KeyedFormSelector<SignupSchema, bool>(
  selector: (form) => form.submitting,
  builder: (context, submitting, _) => ElevatedButton(
    onPressed: submitting ? null : () => form.handleSubmit(context, (value) async { ... }),
    child: submitting
        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
        : const Text('Sign up'),
  ),
),
```

`KeyedFormBuilder` rebuilds on every controller change with no filtering — reach for it only when a widget genuinely needs the whole form's state at once (a debug panel), and prefer the selective forms otherwise.

### Submitting and scrolling to the first error

`form.handleSubmit(context, onValid, {onInvalid, duration, alignment})` wraps `form.submit(...)` with a default `onInvalid` that reveals the first visible error and scrolls it into view via the registry `KeyedForm` already owns — sufficient whenever every field is built eagerly (a plain `Column`, a non-lazy `ListView`). It needs the same descendant `context` as `KeyedForm.controllerOf`.

A field inside a lazily-built region (`ListView.builder`, a `SliverList`) may not have a live scroll anchor yet if it's currently off-screen and was never built — the default reveal then finds nothing to scroll to. For that case, pass a custom `onInvalid` (to `handleSubmit`, or to `form.submit` directly) that first gets the target section built — jump toward it using whatever section-level scroll offset the layout exposes — then, once that section has had a frame to lay out, call `KeyedForm.registryOf<Root>(context).revealFirst(form.visibleErrorKeys)` to do the precise scroll-and-focus. This two-step "coarse jump, then precise reveal" is application code; the library provides `revealFirst` / `reveal` as the precise half, not the section-jump half.

## Lifecycle

Every model and row class needs a real, structural `operator ==` / `hashCode` (generated classes already have this) — the controller's entire "did this write actually change anything" logic, `isDirty`, and `.differs(ref)` are all comparison-based; without it, no-op writes stop being no-ops and dirty tracking stops being meaningful.

One controller, one `dispose()` — call it wherever the `KeyedFormController` is owned (a `StatefulWidget`'s `dispose()`, or wherever else disposes objects with the same lifetime). Anything that hands back its own cleanup callback — `addRelation`'s return value — is not tracked by the controller and must be invoked from that same place.

## Gotchas, in one place

1. Never call `form.setField` / `updateField` / `list` / `mutateList` directly — always `form.field(ref)`.
2. `scopeOf` returning `null` for a written key silently skips revalidation for that write.
3. A resolver under a scoped controller must only return error keys inside the `scope` it was given.
4. Before submit, `onChange`, `onBlur`, and `onTouched` are validation triggers, not equivalent visibility settings; `reValidateMode` governs later automatic validation.
5. A required `int` / `double` / `number` / `enums` field needs `.defaultTo(...)` to generate as non-nullable — `string` / `boolean` don't.
6. `.refine()`'s default error message is the bare `'Invalid'` — every other rule has a real default.
7. Any async `.refine()` anywhere in the schema means every `validate` call in that chain must be the async variant.
8. Build rows with `.create(...)`, never the plain constructor, unless a stable `clientId` is already in hand.
9. Only the root schema's generated class has `validate()` / `validateData()` / `scopeOf` — nested or list-item classes don't.
10. Async validation is declarative and explicit; `FieldHandle.validate()` reruns configured rules. There is no automatic debounce, cancellation, or retry.
11. `unmarkReadOnly(leaf)` does not lift a freeze placed on an ancestor of `leaf`.
12. Read-only survives `seed()` / `reset()`; touched, revealed, validating, and failed do not.
13. `addRelation` does not fire on registration, skips silently while its source is unresolved, and is never auto-disposed.
14. `KeyedForm.controllerOf` / `registryOf` / `handleSubmit` need a context from inside the tree `KeyedForm` builds, never the outer widget's own `build` parameter.
15. Never wire a bound text control's own `onChanged` alongside the field binding — caret and composed-input state break.
16. A default submit-scroll only finds anchors that are currently built — a lazily-built region needs its own `onInvalid`.
17. Model and row classes need real `==` / `hashCode`, or dirty tracking and no-op writes stop working.
18. `KeyedFormState.onBlur` reports actual focus loss; `onTapOutside` alone does not cover keyboard traversal or other focus changes.
