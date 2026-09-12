# keyed_lens

Keyed optics for immutable aggregates — pure Dart, zero dependencies.

Compose typed accessors (`Lens` / `AffineLens`) into an immutable object tree,
where **every accessor carries a `FieldKey`**: a stable, serializable,
structurally-comparable identity (`days.['d1'].groups.['g2'].name`). One value
addresses the same field for reading, writing, diffing — and for any keyed
side-channel you keep next to the data.

That identity is the distinguishing feature, not full optics. There is no
Iso/Traversal and no profunctor machinery: this is the smallest lens core
that also answers *"which field is this?"* in a form you can log, persist and
send over the wire.

## What it's for

Anything that needs to point at a field of an immutable aggregate by a durable
name rather than by position:

- **Editors / forms** — errors keyed by field, per-field dirty checks
  (`lens.differs(original, current)`), focus / scroll targets
- **Undo / redo** — group history entries by `FieldKey`; `set` returns a new
  root and shares the rest
- **Server sync / patches** — a `FieldKey` round-trips as a path string, so
  `{ "path": "days.['d1'].name", "value": … }` maps back to a write
- **Diffing / change tracking** — walk two roots through the same accessors
- **Config / settings screens**, **data-grid cell addressing**
  (`ListItemLens.at(id)`), **deep links into nested state**

The `keyed_form` family (`keyed_form_core` and everything above it) is built on
top of this package — those are consumers, not the reason it exists.

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

## Getting a lens

You write the leaf accessors — each `set` body is a one-liner over your
`copyWith` (freezed, dart_mappable, hand-rolled — this package doesn't care):

```dart
final tourDays = Lens<Tour, List<Day>>.of(
  key: FieldKey.name('days'),
  get: (t) => t.days,
  set: (t, v) => t.copyWith(days: v),
);
```

Compose with `.then(...)` / `.thenTotal(...)`; the behavior **and** the
`FieldKey` concatenate, so a fully composed accessor knows its own identity.

For schema-driven models, [`keyed_form_gen`](https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_gen) generates the
data classes plus a `<Root>Fields` namespace of these accessors from a
`keyed_form_schema` declaration, so you don't hand-write them.

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

The `keyed_form` layers wrap these types under a "field reference" vocabulary
(`FieldRef` / `StrictFieldRef` / `VariantRef` in `keyed_form_core`) so form
code never has to say "lens".

## Scope

`Prism` ships — a minimal type-narrowing optic for composing through the
variants of a sum type. Deliberately out of scope: Iso/Traversal, a
validation DSL (see `keyed_form_schema`), and any state-management,
serialization or Flutter dependency.
