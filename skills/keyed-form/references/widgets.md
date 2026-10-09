# Flutter widgets

## Contents

- `KeyedForm` and context
- Binding one field (including blur and localized errors)
- Binding a dynamic list of rows
- Reading a slice without a full field binding
- Submitting and scrolling to the first error

## `KeyedForm` and context

`KeyedForm<Root>({required controller, translateError, required child})` publishes the controller down the tree. Read it back with `KeyedForm.controllerOf<Root>(context)` / `.registryOf<Root>(context)` / `.translateErrorOf<Root>(context)` — **`context` must come from somewhere inside the subtree `KeyedForm` builds, never the `build(BuildContext context)` parameter of the widget that constructs `KeyedForm` itself.** That outer context sits *above* `KeyedForm` in the tree, so an ancestor lookup from it fails. Use the context a builder callback hands you instead — a `Builder`'s, a `KeyedFormField`'s, a `KeyedFormSelector`'s, a `KeyedFormBuilder`'s. `translateError` (`String Function(BuildContext, String)`) is read once, non-reactively — give it a stable top-level or static function, not a fresh closure every build.

## Binding one field

```dart
KeyedFormField<Root, V>({
  required FieldRef<Root, V> field,
  required builder,
  bool anchor = true,
  bool autoDetectBlur = true,
})
KeyedFormField.text<Root>({
  required FieldRef<Root, String> field,
  bool anchor = true,
  bool autoDetectBlur = true,
  required builder,
})
```

`builder` receives a `KeyedFieldState<V>`: `value`, `onChanged`, `onBlur`,
`errorText` (already mode-gated and translated), `fieldKey`, `isValidating`,
`isFailedValidation`, and `isReadOnly`. It rebuilds only when one of those
values actually changes — a write to any other field is a no-op for this
widget. Focus leaving the `KeyedFormField` subtree calls `onBlur` by default.
Set `autoDetectBlur: false` for a logical control spanning an overlay or other
outside subtree; its owner must call `onBlur` explicitly. `.text` additionally
hands the builder a ready `TextEditingController` kept in caret/IME-safe sync
with the field; never wire that control's own `onChanged` alongside it.

Render `enabled: !state.isReadOnly` (or the equivalent) on the wrapped widget
to grey out a frozen field — `onChanged` stays safe to wire unconditionally.

`onTapOutside` should only unfocus. Enter is not blur, and `onTapOutside` alone
does not cover keyboard traversal or other focus changes. Non-text controls may
use the default detector or call `state.onBlur()` manually, but must have
exactly one blur owner.

Pass `anchor: false` for a field that should never be the scroll target for the
first error (a checkbox, a switch) — otherwise every `KeyedFormField`
registers itself as one automatically.

**Localized errors.** Schema `error:` text reaches `errorText` through `translateError`. To localize, put a stable message key in the schema (for example `error: .text('signup.emailRequired')`) and map it to the translated string in `translateError` or at the widget.

## Binding a dynamic list of rows

```dart
KeyedFieldList<Root, Item extends KeyedRow>({
  required FieldRef<Root, List<Item>> field,
  required Widget Function(BuildContext, List<Item> items, KeyedFormList<Root, Item> list) builder,
})
```

rebuilds only when the row *set* (its ids, in order) changes — adding, removing, or reordering a row — never for an edit to a value inside one row; give each row's own subtree a `ValueKey` on its `clientId` so its nested `KeyedFormField`s stay stable across that rebuild. `list` is the same row editor `form.field(field).list()` returns.

When something outside the list also needs the live row-id sequence for its own purpose (driving a key per row for scroll offsets, say), track it by hand with the same "compare the id list in order, rebuild only on a real change" approach instead, reading rows straight off `form.field(field).list()`.

## Reading a slice without a full field binding

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

## Submitting and scrolling to the first error

`form.handleSubmit(context, onValid, {onInvalid, duration, alignment})` wraps `form.submit(...)` with a default `onInvalid` that reveals the first visible error and scrolls it into view via the registry `KeyedForm` already owns — sufficient whenever every field is built eagerly (a plain `Column`, a non-lazy `ListView`). It needs the same descendant `context` as `KeyedForm.controllerOf`.

A field inside a lazily-built region (`ListView.builder`, a `SliverList`) may not have a live scroll anchor yet if it's currently off-screen and was never built — the default reveal then finds nothing to scroll to. For that case, pass a custom `onInvalid` (to `handleSubmit`, or to `form.submit` directly) that first gets the target section built — jump toward it using whatever section-level scroll offset the layout exposes — then, once that section has had a frame to lay out, call `KeyedForm.registryOf<Root>(context).revealFirst(form.visibleErrorKeys)` to do the precise scroll-and-focus. This two-step "coarse jump, then precise reveal" is application code; the library provides `revealFirst` / `reveal` as the precise half, not the section-jump half.
