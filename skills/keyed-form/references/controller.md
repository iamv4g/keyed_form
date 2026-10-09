# Controller

## Contents

- Constructor
- Validation triggers
- Scoped validation
- Reading and writing one field
- Declarative async validation
- Validating and submitting
- Read-only fields
- Deriving one field from another
- Lifecycle

## Constructor

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

## Validation triggers

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

How a field reports blur is covered in `widgets.md` ("Binding one field").

## Scoped validation

Without `scopeOf`, an automatic write validates the whole draft. With
`scopeOf`, the resolver validates the mapped subtree; returning `null` skips
automatic validation for that event. Out-of-scope resolver keys trip a debug
assertion. `validate()` and `submit()` always validate the full draft;
`validateScopes()` explicitly validates the requested subtrees whether or not
`scopeOf` is configured.

## Reading and writing one field

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

## Declarative async validation

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
`.forEach(list: ..., rules: [...])`, nested `.field` callbacks receive
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

## Validating and submitting

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

## Read-only fields

`form.markReadOnly(key)` / `.unmarkReadOnly(key)` / `.isReadOnly(key)` (or the typed `form.field(ref).markReadOnly()` / `.unmarkReadOnly()` / `.isReadOnly`) freeze a field against `.set` / `.update` / list mutation, without touching validation — a frozen field still validates normally. Freezing covers every field nested under the given key too, so freezing a whole row or section needs one call at that key, not one per leaf. `unmarkReadOnly` on a leaf does not undo a freeze placed on one of its ancestors — unmark the ancestor's own key instead. Pass `force: true` to a write to bypass the freeze for that one call only.

Read-only status is configuration, not draft state: it is the one piece of bookkeeping that **survives** `seed()` / `reset()` — touched, revealed, validating, and failed all clear, read-only does not.

## Deriving one field from another

```dart
VoidCallback addRelation<S, D>(
  FieldRef<Root, S> source,
  D Function(S value) select,
  void Function(D value) onChange,
)
```

Calls `onChange` with the selected slice of `source` whenever it actually changes (compared with `==`) — registering it does not itself call `onChange`, since it primes its own baseline from the current value first, and only a later change fires it. It skips silently while `source` doesn't currently resolve (a removed row) rather than treating the gap as a change. It returns a callback that unsubscribes — call it wherever the controller itself is disposed; nothing here is tracked or cleaned up automatically.

## Lifecycle

Every model and row class needs a real, structural `operator ==` / `hashCode` (generated classes already have this) — the controller's entire "did this write actually change anything" logic, `isDirty`, and `.differs(ref)` are all comparison-based; without it, no-op writes stop being no-ops and dirty tracking stops being meaningful.

One controller, one `dispose()` — call it wherever the `KeyedFormController` is owned (a `StatefulWidget`'s `dispose()`, or wherever else disposes objects with the same lifetime). Anything that hands back its own cleanup callback — `addRelation`'s return value — is not tracked by the controller and must be invoked from that same place.
