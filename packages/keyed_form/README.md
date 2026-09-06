# keyed_form

A form-state controller for immutable aggregates — the react-hook-form of
the `keyed_form` family. Pure Dart, no Flutter dependency.

`KeyedFormController<Root>` owns the editable draft, the field-keyed
validation errors, and the touched/dirty/revealed bookkeeping that decides
*when* an error is shown. Reads, writes, validation lookups and dirty
checks all speak the `FieldRef` vocabulary from
[`keyed_form_core`](../keyed_form_core), re-exported here — so UI code
addresses a field the same way whether it is reading it, writing it, or
asking for its error.

Observability is `ChangeNotifier` from `package:listen` (the official
Flutter-team observable package), so the controller can live in a plain
Dart test, a CLI, or — via [`keyed_form_flutter`](../keyed_form_flutter) —
a widget tree.

## Usage

```dart
final form = KeyedFormController<InvoiceForm>(
  initialValue: const InvoiceForm(),
  mode: KeyedFormMode.onTouched,
  resolver: (draft, _) => InvoiceForm.validateData(draft),
);

form.setField(InvoiceFields.customerEmail, 'ada@example.com');
form.visibleError(InvoiceFields.customerEmail.key); // null until touched / submitted

form.validate(); // whole-draft validation, reveals every error
```

## Pieces

- `KeyedFormController<Root>` — the draft, `errors`, `touched`, `revealed`,
  `submitted`/`submitting`, plus `setField`/`updateField`, `touch`,
  `validate`/`validateScopes`, `seed`/`reset`, and server-error merging
  (`setServerErrors`/`setServerErrorPaths`).
- `KeyedFormMode` — when a field's error becomes *visible*
  (`onChange`/`onBlur`/`onTouched`/`onSubmit`/`all`), mirroring
  react-hook-form's modes. The controller never hides an error a submit
  attempt surfaced, nor one explicitly `reveal`ed.
- `KeyedFormResolver<Root>` / `KeyedFormScopeOf` — a validation function
  `(draft, scope) => FieldErrors<String>`, and an optional
  written-field-to-subtree mapper so a large aggregate can re-validate one
  subtree at a time instead of the whole draft on every keystroke.
- `KeyedFormList<Root, Item>` — a by-id editor for one list field
  (`append`/`insert`/`removeById`/`move`/`updateById`, …), the
  `useFieldArray` of this family. Obtain one with
  `form.list(InvoiceFields.lineItems)`.
- `KeyedFormSnapshot<Root>` — an immutable, `==`-comparable point-in-time
  copy of the controller's coarse state, for hosts (Riverpod `Notifier`,
  …) that want a value rather than a listenable.

## Scoped validation

For a large aggregate, pass `scopeOf` so each write re-validates only the
subtree it falls under instead of the whole draft:

```dart
KeyedFormController<InvoiceForm>(
  initialValue: const InvoiceForm(),
  resolver: (draft, scope) => InvoiceForm.validateData(draft, scope: scope),
  scopeOf: (key) => key.prefix(2), // lineItems.[id]. … → that line item's scope
);
```

`validateScopes` re-validates and force-reveals a set of subtrees at once —
the "validate every dirty row before saving" operation — and returns which
of them still fail.

## Scope

Deliberately out of scope: widgets (that is
[`keyed_form_flutter`](../keyed_form_flutter)), schema/validation DSL (that
is [`keyed_form_schema`](../keyed_form_schema)), and any serialization format for the
draft itself.
