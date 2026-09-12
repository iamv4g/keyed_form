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
tree, so an ancestor lookup from it fails).

## Pieces

| Piece | What it is |
|---|---|
| `KeyedForm<Root>` | Publishes a `KeyedFormController<Root>` down the widget tree and owns a `KeyedFieldRegistry` internally — apps never construct one. `controllerOf` / `registryOf` / `translateErrorOf` read it back from a descendant context (see the context rule above) |
| `KeyedFormField<Root, V>` | Binds one `FieldRef` to the ambient controller — see below |
| `KeyedFieldList<Root, Item>` | Binds one list field and rebuilds only when the row set changes (add/remove/reorder); edits *within* a row are the job of the `KeyedFormField`s inside it |
| `context.watchField(ref)` / `context.watchForm<Root>()` / `context.selectForm((f) => slice)` | Read a form slice in a widget's `build()` and rebuild that widget only when the slice changes. Non-reactive reads (`form.field(x).value`, `form.isDirty` in an event handler) are plain getters, no subscription |
| `KeyedFormSelector<Root, T>` | The `context.selectForm` above wrapped in a widget, to scope the rebuild to a subtree, with a non-rebuilt `child` |
| `KeyedFormBuilder<Root>` | Rebuilds on *every* controller change — the escape hatch for a widget that genuinely needs the whole state (a live inspector) |
| `KeyedTextBinding` | A `TextEditingController` two-way bound to an external string value, keeping the caret and IME composing region stable as the value round-trips through the form controller. Design-system agnostic |
| `form.handleSubmit(context, onValid, {onInvalid})` | Validates, and on success runs `onValid` with the draft while toggling `submitting` — see below |
| `KeyedFieldRegistry` / `KeyedFieldAnchor` | Maps `FieldKey`s to live field positions so a form can scroll to (and focus) a field it only knows by identity; `handleSubmit` uses this for you — reach for it directly only for a custom `onInvalid` |

**`KeyedFormField`** rebuilds only when that field's value, visible error,
`isValidating`, `isFailedValidation`, or `isReadOnly` changes.
`KeyedFormField.text` bundles a `KeyedTextBinding` for a `String` field.
Wraps its builder output in a `KeyedFieldAnchor` automatically
(`anchor: false` to opt out) so it participates in scroll-to-first-error
without extra wiring. `KeyedFieldState.isValidating` mirrors
`form.field(ref).isValidating` — render a spinner from it while a field's
own async check (`form.field(ref).validateAsync(...)`) is running;
`isFailedValidation` mirrors a check that threw or timed out (distinct from
`errorText`); `isReadOnly` mirrors a frozen field — pair it with
`enabled: !state.isReadOnly` on the wrapped widget (`onChanged` stays safe
to wire unconditionally, since the controller already no-ops a frozen
write).

**`handleSubmit`** — on failure its default `onInvalid` reveals the first
visible error via the ambient `KeyedFieldRegistry`. Pass `onInvalid` to
override for custom invalid-handling (e.g. scrolling a lazily-built section
list first).

## Scope

Deliberately out of scope: any specific design system (buttons, inputs,
layout) — this package binds *state*, not presentation.
