# keyed_form

A form-state controller for immutable aggregates. Pure Dart, no Flutter
dependency.

`KeyedFormController<Root>` owns the editable draft, the field-keyed
validation errors, and the touched/dirty/revealed bookkeeping that decides
*when* an error is shown. Reads, writes, validation lookups and dirty
checks all speak the `FieldRef` vocabulary from
[`keyed_form_core`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_core), re-exported here — so UI code
addresses a field the same way whether it is reading it, writing it, or
asking for its error.

Observability is `ChangeNotifier` from `package:listen` (the official
Flutter-team observable package), so the controller can live in a plain
Dart test, a CLI, or — via [`keyed_form_flutter`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter) —
a widget tree.

For the full documentation, guides, and examples, visit
[keyed-form.v4g.space](https://keyed-form.v4g.space).

## Usage

```dart
final form = KeyedFormController<InvoiceForm>(
  initialValue: const InvoiceForm(),
  mode: KeyedFormMode.onTouched,
  resolver: InvoiceForm.validateData,
  asyncValidators: [
    .field(
      field: InvoiceFields.customerEmail,
      validate: (_, email) => api.checkEmailAvailable(email),
      timeout: const Duration(seconds: 5),
    ),
  ],
);

form.field(InvoiceFields.customerEmail).set('ada@example.com');
final result = await form.validate();
print('valid: ${result.isValid}');

await form.submit(
  (value) => api.save(value),
  onInvalid: (keys) => print('invalid values: $keys'),
  onValidationUnavailable: (result) =>
      print('checks unavailable: ${result.failures.keys}'),
);
```

`submit` always runs a fresh validation. `onValid` runs only when there are
no value errors and no blocking technical failures.

`form.field(ref)` returns a `FieldHandle` — a statically-typed per-field
facade (`set` / `update` / `value` / `error` / `dirty` / `touch()`, and
`list()` for a list field). It is the everyday way in and out of a field;
`.set(value)` rejects a wrongly-typed value at compile time.

A field's async rule is configured declaratively on the controller. While it
runs, `FieldHandle.isValidating` is true; a returned message is a value error,
while a thrown exception or timeout is a technical failure:

```dart
KeyedFormAsyncValidator.field(
  field: InvoiceFields.customerEmail,
  validate: (_, email) => api.checkEmailAvailable(email),
  timeout: const Duration(seconds: 5),
);
```

Reading the controller's getters (`form.value`, `form.field(x).value`,
`form.isDirty`) is non-reactive — the `getValues` of this family, for event
handlers. To *watch* a slice in a widget's `build`, use `keyed_form_flutter`'s
`context.watchField` / `context.watchForm` / `context.selectForm`.

## Pieces

| Piece | What it is |
|---|---|
| `KeyedFormController<Root>` | Owns draft, error sources, validation state, lifecycle; `validate()` / `validateScopes()` return `KeyedFormValidationResult`; `submit(onValid, {onInvalid, onValidationUnavailable})` |
| `KeyedFormAsyncValidator<Root>` | Typed declarative async field and row-local validation rules |
| `FieldHandle<Root, V>` | What `form.field(ref)` returns — `set`/`update`, `value`/`error`/`dirty`/`key`, `isValidating`/`isFailedValidation`, `validate()` for a configured rule, `touch()`, and `list()` for list fields |
| `markReadOnly()` / `unmarkReadOnly()` / `isReadOnly` | Freeze a field against writes without affecting validation — see below |
| `form.addRelation(source, select, onChange)` | Derive one field's value from another — see below |
| `KeyedFormMode`, `KeyedFormReValidateMode` | Configure validation triggers before and after submit |
| `KeyedFormResolver<Root>` / `KeyedFormScopeOf` | Sync validation function `(draft, scope) => FieldErrors<String>` and optional written-field-to-subtree mapper |
| `KeyedFormList<Root, Item>` | By-id list editing; obtain one with `form.field(ref).list()` |
| `KeyedFormSnapshot<Root>` | Immutable point-in-time copy of coarse controller state |

`validate()` performs whole-draft validation and reveals its result but does
not mark the form submitted. `submit()` always uses a fresh snapshot; a
draft change, reset, seed, or disposal during the attempt prevents saving it.

| Mode | Before first submit | After submit |
|---|---|---|
| `onSubmit` | No automatic validation | `reValidateMode` (`onChange` by default) |
| `onChange` | Validate on writes | Continue write validation |
| `onBlur` | Validate on blur | Continue blur validation |
| `onTouched` | Validate on first blur, then writes | `reValidateMode` (`onChange` by default) |
| `all` | Validate on writes and blur | Continue both triggers |

Initial values, `seed`, and `reset` do not eagerly validate. `touch()` reports
blur: it records interaction and runs the configured blur trigger, but does
not force-reveal errors independently of validation visibility.

Technical failures are not value errors. The controller defaults to
`KeyedFormAsyncFailureMode.blockSubmit`; a rule can choose
`KeyedFormAsyncFailureMode.allowSubmit`. When all failures are allowed and no
value errors remain, `onValid` can run even though a remote check did not
complete; the server may still reject the value. Superseded results never
authorize submission.

An explicit validation result remains `unavailable` (`isValid == false`) when
any technical check fails, including an `allowSubmit` rule. `submit()` applies
the failure policy separately.

**Read-only** — freezing a key also freezes, by `FieldKey` ancestor
coverage, everything nested under it. Pass `force: true` to `set`/`update`
to write through the freeze. Read-only is configuration: it survives
`seed()`/`reset()`, unlike touched/revealed/validating/failed.

**`addRelation`** — calls `onChange` with the selected slice of `source`
whenever it actually changes; registering it does not itself call
`onChange`. Returns a callback to unsubscribe — the controller does not
track or dispose relations for you.

## Scoped validation

For a large aggregate, pass `scopeOf` so each write re-validates only the
subtree it falls under instead of the whole draft. `keyed_form_gen` wires this
up for you — `InvoiceForm.validateData` honours the scope and
`InvoiceForm.scopeOf` (which delegates to `rowScopeOf`) is a sensible default:

```dart
KeyedFormController<InvoiceForm>(
  initialValue: const InvoiceForm(),
  resolver: InvoiceForm.validateData,
  scopeOf: InvoiceForm.scopeOf, // or your own: (key) => key.prefix(2)
);
```

`validateScopes` re-validates and force-reveals a set of subtrees at once —
the "validate every dirty row before saving" operation — and returns which
of them still fail. Cross-field `.refine(...)` rules that sit *above* the
written scope only re-run on a full `validate()` (or `validateScopes` covering
them), so keep calling `validate()` on submit.

## Scope

Deliberately out of scope: widgets (that is
[`keyed_form_flutter`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter)), schema/validation DSL (that
is [`keyed_form_schema`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_schema)), and any serialization format for the
draft itself.
