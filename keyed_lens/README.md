# keyed_lens

Keyed optics for immutable aggregates — pure Dart, no Flutter.

**Not** a general-purpose optics library. Every lens here carries a
`FieldKey`: a stable, serializable, structurally-comparable identity
(`days.d1.groups.g2.name`). That coupling is the point — it is what lets
one abstraction address a field across every concern of a structured
editor:

- validation errors keyed by field (`FieldErrors`, looked up by lens)
- per-field dirty checks (`lens.differs(original, current)`)
- focus / scroll-to-error targets
- undo grouping and server patches (a `FieldKey` round-trips as a path)

## Pieces

- `FieldKey` + sealed `Segment` (`NameSegment` / `IdSegment`) — identity.
  Composes by concatenation, mirroring lens composition.
- `Lens<Root, Value>` (total) / `AffineLens<Root, Value>` (target may be
  missing). Affine law: `find` → `None` and `set`/`update` → no-op when the
  path doesn't resolve, so stale lenses held by in-flight UI events are
  harmless by construction.
- `ListItemLens` / `.at(id, matches)` — by-id row access (never by index;
  ids keep keys valid across sibling insert/remove).
- `whenPresent()` — refines `AffineLens<Root, V?>` to `AffineLens<Root, V>`.
- `Opt` (`Some`/`None`) — internal distinction between "path missing" and
  "present but null"; prefer `getOrNull`/`update` in application code.
- `FieldErrors<E>` — callable, `FieldKey`-keyed error container:
  `errors(lens)`.

## FieldKey serialization

`FieldKey` has a frozen, reversible wire format: `toPath()` /
`FieldKey.parse` (throws `FormatException` on malformed input) /
`FieldKey.tryParse` (null instead). It is the inverse pair —
`FieldKey.parse(k.toPath()) == k` for every key built from `String`/`int`
ids — meant for logs and any future persisted payload.

`toString()` is a separate, **debug-only** rendering: pretty but lossy
(`days.d1.name` — a name and a same-text id both render bare), so it does
**not** parse back. Use `toPath()` whenever you need a round trip.

Dot-separated bracket style — every segment is separated by `.`, the first
token has no leading separator, the root key is the empty string:

| Segment | Encodes to | Notes |
| --- | --- | --- |
| `NameSegment(name)` | `esc(name)` | reserved `% . [ ]` are percent-encoded (`%XX`, uppercase hex, UTF-8 bytes); unicode passes through raw; empty name → `ArgumentError` |
| `IdSegment(int)` | `[42]` | canonical decimal (optional `-`, no leading zeros, no `-0`) |
| `IdSegment(String)` | `['…']` | only `\`→`\\` and `'`→`\'` escaped; empty string legal (`['']`) |

Examples: `days.['d1'].groups.['g2'].name` · `days.[3].note` ·
`['d1'].name` (id-first) · `days.['a.b'].name` (dots inside quotes need no
escaping) · name `a.b` → `a%2Eb`.

**Id-type policy.** Only `String` and `int` ids serialize; any other runtime
id type throws `ArgumentError` at encode time. Ids modeled as extension types
over `String`/`int` erase to their representation, so they are supported
implicitly and compare equal to the raw-typed key (`FieldKey.id(DayId('d1'))
== FieldKey.id('d1')`). `String` and `int` stay distinct end to end:
`FieldKey.id('42')` encodes `['42']`, `FieldKey.id(42)` encodes `[42]`.

**Deliberately absent: a FieldKey→lens resolver** (mapping a serialized path
from *outside* — a server patch or deep link — back to a lens). There is no
consumer for it yet; it earns its own story when server patches or deep links
arrive, as a new named codec would rather than a change to this frozen one.

Normally you don't hand-write lenses: [`keyed_form_gen`](../keyed_form_gen)
turns a `keyed_schema` declaration into the data classes, a `<Root>Fields`
namespace, and `<Field>FieldRefs` wrappers keyed by field name. Hand-authoring is the escape
hatch — each segment `set` body is a one-liner over your `copyWith`
(dart_mappable, freezed, hand-rolled — this package doesn't care):

```dart
final tourDays = Lens<Tour, List<Day>>.of(
  key: FieldKey.name('days'),
  get: (t) => t.days,
  set: (t, v) => t.copyWith(days: v),
);
```

## `FieldRef` aliases

For form / editor layers that shouldn't have to talk about optics,
`FieldRef<R, V>` aliases `AffineLens` and `TotalFieldRef<R, V>` aliases
`Lens` — same types, "field reference" vocabulary. `keyed_form_gen` emits
its wrapper leaf getters as `FieldRef`.

The Flutter layer (text binding, field anchors) lives in
[`keyed_form_flutter`](../keyed_form_flutter).

## Scope

`Prism` ships (a minimal type-narrowing optic — `keyed_form_gen` uses it to
compose through discriminated-union variants). Deliberately out of scope:
Iso/Traversal, a validation DSL (that is `keyed_schema`), any
state-management or serialization dependency.
