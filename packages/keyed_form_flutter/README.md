# keyed_form_flutter

The Flutter binding for [`keyed_form`](../keyed_form).

Wrap an editor subtree in a `KeyedForm` to publish its
`KeyedFormController`, then address individual fields with `KeyedFormField`,
lists with `KeyedFieldList`, and any other slice (a dirty badge, a summary
line) with `context.watchField` / `context.selectForm` — each rebuilds only
when its own slice of the form changes, not on every keystroke elsewhere in
the tree. `KeyedTextBinding` covers caret-stable text input;
`form.handleSubmit(context, onValid)` validates and reveals the first error
for you on failure.

Re-exports all of `keyed_form` (and thus `keyed_form_core`), so a screen needs a
single import.

## Usage

```dart
KeyedForm<InvoiceForm>(
  controller: form,
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
      Builder(
        builder: (context) => SaveButton(
          onPressed: () => form.handleSubmit(context, (value) => api.save(value)),
        ),
      ),
    ],
  ),
)
```

`context` for `handleSubmit` must come from inside the `KeyedForm` subtree —
the `context` a builder callback hands you (as above), not the `context` of
the `State` that *created* the `KeyedForm` (that one sits above it in the
tree). Same rule as Flutter's own `Form.of(context)`.

## Pieces

- `KeyedForm<Root>` — the `Form` of this family. Publishes a
  `KeyedFormController<Root>` down the widget tree (the controller is a
  `package:listen` `ChangeNotifier`, so descendants subscribe to it directly
  and rebuild selectively) and owns a `KeyedFieldRegistry` internally — apps
  never construct one. `KeyedForm.controllerOf` / `registryOf` /
  `translateErrorOf` read the ambient scope back from a *descendant*
  context, same rule as `Form.of(context)`.
- `KeyedFormField<Root, V>` — binds one `FieldRef` to the ambient
  controller and rebuilds only when that field's value, visible error, or
  `isValidating` changes. `KeyedFormField.text` bundles a `KeyedTextBinding`
  for a `String` field. Wraps its builder output in a `KeyedFieldAnchor`
  automatically (`anchor: false` to opt out) so it participates in
  scroll-to-first-error without extra wiring. `KeyedFieldState.isValidating`
  mirrors `form.field(ref).isValidating` — render a spinner from it while a
  field's own async check (`form.field(ref).validateAsync(...)`) is running.
- `KeyedFieldList<Root, Item>` — binds one list field and rebuilds only
  when the row set changes (add/remove/reorder); edits *within* a row are
  the job of the `KeyedFormField`s inside it. The analogue of
  react-hook-form's `useFieldArray`.
- `context.watchField(ref)` / `context.watchForm<Root>()` /
  `context.selectForm((f) => slice)` — read a form slice in a widget's
  `build()`, get the value back, and rebuild that widget only when the slice
  changes. `watchField` is react-hook-form's `watch("name")` (returns the
  value; its error/dirty are on the controller); `watchForm` is `watch()`;
  `selectForm` is bloc's `context.select`. Non-reactive reads
  (`form.field(x).value`, `form.isDirty` in an event handler) are the
  `getValues` side — plain getters, no subscription.
- `KeyedFormSelector<Root, T>` — the `context.selectForm` above wrapped in a
  widget, to scope the rebuild to a subtree (with a non-rebuilt `child`) —
  `provider`'s `Selector` alongside its `context.select`.
- `KeyedFormBuilder<Root>` — rebuilds on *every* controller change; the
  escape hatch for a widget that genuinely needs the whole state (a live
  inspector).
- `KeyedTextBinding` — a `TextEditingController` two-way bound to an
  external string value, keeping the caret and IME composing region stable
  as the value round-trips through the form controller. Design-system
  agnostic: plug the controller it hands you into any text field.
- `form.handleSubmit(context, onValid, {onInvalid})` — the react-hook-form
  `handleSubmit` of this family: validates, and on success runs `onValid`
  with the draft while toggling `submitting`; on failure its default
  `onInvalid` reveals the first visible error via the ambient
  `KeyedFieldRegistry`. Pass `onInvalid` to override for custom
  invalid-handling (e.g. scrolling a lazily-built section list first).
- `KeyedFieldRegistry` / `KeyedFieldAnchor` — maps `FieldKey`s to live
  field positions so a form can scroll to (and focus) a field it only
  knows by identity; `handleSubmit` uses this for you — reach for it
  directly only for a custom `onInvalid`.

## Scope

Deliberately out of scope: any specific design system (buttons, inputs,
layout) — this package binds *state*, not presentation.
