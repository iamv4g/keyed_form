# keyed_form_flutter

The Flutter binding for [`keyed_form`](../keyed_form).

Wrap an editor subtree in a `KeyedFormScope` to publish its
`KeyedFormController`, then address individual fields with `KeyedFormField`
and lists with `KeyedFieldList` — each rebuilds only when its own slice of
the form changes, not on every keystroke elsewhere in the tree.
`KeyedTextBinding` and `KeyedFieldRegistry` cover caret-stable text input
and scroll-to-first-error.

Re-exports all of `keyed_form` (and thus `keyed_lens`), so a screen needs a
single import.

## Usage

```dart
KeyedFormScope<InvoiceForm>(
  controller: form,
  registry: registry,
  child: Column(
    children: [
      KeyedFormField<InvoiceForm, String>(
        field: InvoiceFields.customerEmail,
        builder: (context, f) => TextInput(
          value: f.value ?? '',
          onChanged: f.onChanged,
          onTouched: f.onBlur,
          errorText: f.errorText,
          label: Text('Email'),
        ),
      ),
      KeyedFieldList<InvoiceForm, LineItem>(
        field: InvoiceFields.lineItems,
        builder: (context, items, list) => Column(children: [
          for (final item in items)
            LineItemCard(key: ValueKey(item.clientId), id: item.clientId),
          AddButton(onPressed: () => list.append(LineItem.create())),
        ]),
      ),
    ],
  ),
)
```

## Pieces

- `KeyedFormScope<Root>` — an `InheritedWidget` (not `InheritedNotifier`:
  the controller is a `package:listen` `ChangeNotifier`, so descendants
  subscribe to it directly and rebuild selectively) publishing a
  `KeyedFormController<Root>`, a `KeyedFieldRegistry`, and an optional
  `KeyedErrorTranslator` for i18n.
- `KeyedFormField<Root, V>` — binds one `FieldRef` to the ambient
  controller and rebuilds only when that field's value or visible error
  changes. `KeyedFormField.text` bundles a `KeyedTextBinding` for a
  `String` field. Wraps its builder output in a `KeyedFieldAnchor`
  automatically (`anchor: false` to opt out) so it participates in
  scroll-to-first-error without extra wiring.
- `KeyedFieldList<Root, Item>` — binds one list field and rebuilds only
  when the row set changes (add/remove/reorder); edits *within* a row are
  the job of the `KeyedFormField`s inside it. The analogue of
  react-hook-form's `useFieldArray`.
- `KeyedTextBinding` — a `TextEditingController` two-way bound to an
  external string value, keeping the caret and IME composing region stable
  as the value round-trips through the form controller. Design-system
  agnostic: plug the controller it hands you into any text field.
- `KeyedFieldRegistry` / `KeyedFieldAnchor` — maps `FieldKey`s to live
  field positions so a form can scroll to (and focus) a field it only
  knows by identity — `registry.revealFirst(form.visibleErrorKeys)` after
  a failed submit.

## Scope

Deliberately out of scope: any specific design system (buttons, inputs,
layout) — this package binds *state*, not presentation.
