# keyed_form_benchmark

A DX + performance comparison harness:
**`keyed_form` vs `reactive_forms`, `flutter_form_builder` and `formz`**.

Not published, not a workspace dependency of anything — it only *consumes* the
libraries so they can be driven through one interface against one form shape.
`formz` ships no widget layer, so its widget row is `formz + flutter_bloc` —
the pairing from formz's own example.

```
tool/run.sh                       # parity gate + every suite, JSON -> benchmark_results/
flutter test test/parity_test.dart
flutter test test/model_benchmark_test.dart  --tags benchmark
flutter test test/rebuild_benchmark_test.dart --tags benchmark
```

Those run under **JIT** on the host — ~2–3× slower and noisier than a real
app. For release-representative numbers swept to large N (the only place the
`keyed_form_flutter` listener fan-out could bite), run the AOT suite on a
device:

```
flutter create --platforms=macos .            # once; runner is git-ignored
flutter test integration_test/aot_benchmark_test.dart --profile -d macos
```

(`--platforms=ios`/`android` + `-d <id>` for a device/emulator.)

## What is measured against what

One form shape (`lib/scenario.dart`), swept by size:

* `fieldCount` flat text fields, each **required + minLength(3)**;
* `rowCount` rows in one dynamic list — `{ city required, nights int }`;
* one cross-field rule: `sum(nights) <= maxNights`.

The rules are deliberately trivial so the numbers reflect each **library's
bookkeeping** (copy / diff / validate-dispatch / notify / rebuild), not
validator cost.

| library | version | field value type | write dispatch | dirty | validity |
|---|---|---|---|---|---|
| `keyed_form` | 0.1.0 (this repo) | immutable draft, `FieldRef` lens | resolver re-run (whole draft, or scoped subtree) | whole-draft `==` | `errors.isEmpty` |
| `reactive_forms` | 18.2.2 | `FormControl<T>` + streams | that control's validators + parent status bubble | per-control flag | cached status |
| `flutter_form_builder` | 10.3.x¹ | `FormBuilderField` widget state | `didChange` on the field's `State` | `any(field.isDirty)` | `every(field.isValid)` |
| `formz` | 0.8.1 | `FormzInput<T,E>` in a hand-rolled state object | **nothing** — you rebuild the state object yourself | `any(!input.isPure)` | O(N) — re-runs every `validator` on read |

¹ pinned `<11.0.0`: 11.x moved off `package:flutter/material` onto
`package:material_ui`, which most apps have not adopted. 11.x is otherwise the
same `FormBuilderField` / `State.didChange` model, so its bookkeeping numbers
carry over.

`formz` does **no** automatic recomputation: you own the immutable state
object and its `copyWith`, and `isValid` re-runs every input's `validator` on
each access (no cache unless the input adds `FormzInputErrorCacheMixin`). So
its cost sits at read time, not write time, and stays O(N) in the field count.

`formz` also ships **no widget layer**, so its widget-sweep row is
`formz + flutter_bloc` — a cubit holds the `FormzInput` state and each field
is a plain `TextField` under a `BlocSelector` on its own slice, the pattern
from formz's own example. What that row measures is `flutter_bloc`'s rebuild
granularity (formz just supplies the model) — a fair entry, since every
library's widget layer is a separate concern (`keyed_form_flutter` is a
separate package too).

Three `keyed_form` wirings are run:

* **whole** — hand-written resolver re-checks everything on every write;
* **scoped** — hand-written resolver + `scopeOf`, so a flat-field write only
  re-validates that field (the apples-to-apples match for reactive_forms'
  per-control model);
* **keyed_form_gen** — a real generated `Bench100Schema` whose `validateData`
  round-trips through `toMap()` + the `ks.*` schema (calibration test only,
  fixed at 100 flat fields; a generated model cannot scope its validation).

`flutter_form_builder` has **no model layer** — it does nothing without a
widget tree — so it appears only in the widget benchmark.

`test/parity_test.dart` is the fairness gate: it asserts all harnesses model
the same form and agree on validity/dirty/row-count through a scripted edit
sequence. Run it before trusting any number.

## Results snapshot

> Debug `flutter test` on an M-series laptop, 2026-09. **Rebuild counts are
> deterministic**; µs figures are directional only — for real latency run in
> profile mode on a device.

### Model layer — `flutter test test/model_benchmark_test.dart` (median µs)

`keyed_form` here is the list-backed stand-in with a **hand-written resolver**.

| op | lib | 10f | 50f | 100f | 250f |
|---|---|--:|--:|--:|--:|
| **build** | keyed_form | ~1 | ~1 | ~1 | 3 |
| | reactive_forms | 200 | 390 | 750 | 1750 |
| | formz | ~0 | ~0 | ~0 | 1 |
| **setField** (1 write + revalidate) | keyed_form (whole) | 11 | 5 | 8 | 21 |
| | keyed_form (scoped) | 10 | 5 | 8 | 22 |
| | reactive_forms | 22 | 18 | 23 | 35 |
| | formz (no validation on write) | ~0 | ~0 | ~0 | ~0 |
| **isDirty** | keyed_form (`==` whole draft) | 0.02 | 0.03 | 0.02 | 0.02 |
| | reactive_forms (flag) | ~0 | ~0 | ~0 | ~0 |
| | formz (`any(!isPure)`) | 0.02 | 0.02 | 0.02 | 0.02 |
| **isValid** | keyed_form / reactive_forms (cached) | ~0 | ~0 | ~0 | ~0 |
| | formz (re-runs N validators) | 0.14 | 0.59 | 1.15 | 2.82 |

Row churn (`addRow + removeRow`, 20f+20r): keyed_form ~17–23 µs,
reactive_forms ~65 µs, formz ~0 µs (list copy, no validation).

Takeaways: `keyed_form` builds a form ~100–500× cheaper than `reactive_forms`
(no per-field control/stream objects). With a hand-written resolver it also
writes ~2–3× cheaper. The "immutability tax" on `isDirty` — a full-draft `==`
every check — is **not** measurable at these sizes. `scoped` vs `whole` barely
differ here because the ruleset is tiny.

`formz` looks free on every write because it *is* — it validates nothing until
you read `isValid`, and that read is O(N) (every `validator` re-runs, uncached).
With the trivial rules here that is still sub-3 µs at 250 fields, but it is the
one number that grows with the form, and it runs on **every** rebuild that
reads validity. `keyed_form` and `reactive_forms` pay once at write time and
cache. Same trade `formz` makes explicit with `FormzInputErrorCacheMixin` for
expensive validators. `formz` also has no notion of the form as a whole: the
cross-field `sum(nights)` rule and the "row set changed" part of `isDirty` are
hand-written in the harness, not the library.

### Codegen calibration — `test/codegen_calibration_test.dart` (100 flat fields, median µs)

The list-backed stand-in above uses a hand-written resolver. A real
`keyed_form_gen` model validates by re-running the `ks.*` schema over the
object's fields on every write; `scoped` wires the generated
`Bench100Schema.scopeOf` so a write re-checks only its own field.

| lib | build | setField median | setField min |
|---|--:|--:|--:|
| keyed_form — list-backed + hand resolver (whole) | 4 | **9** | 9 |
| keyed_form — list-backed + hand resolver (scoped) | 1 | 11 | 11 |
| **keyed_form_gen — real `Bench100Schema` + `validateData`** | 3 | **11** | **9** |
| **keyed_form_gen (scoped)** | 3 | **10** | **9** |
| reactive_forms | 800 | 23 | 22 |
| formz (no validation on write; O(N) `isValid` read = ~1.2 µs) | 1 | **~0** | ~0 |

Scoping barely moves the needle **here** — a flat form still costs one O(N)
pass to find the one in-scope field (the hand-written scoped resolver has the
same shape: it too builds and checks all 100 keys). Where `scopeOf` actually
pays off is a **nested / large-list** form: scoping a write to one row skips
every *other* row's nested-object validation, turning `O(rows × fieldsPerRow)`
into `O(fieldsPerRow)`. AOT: the flat scoped write is ~3.4 µs vs ~4.0 µs
unscoped.

The idiomatic `keyed_form_gen` write is level with a hand-written resolver and
~2× faster than reactive_forms. Two changes got it there (controlled
before/after — reverting just the schema/generator files — measured it at
~28 µs before):

1. `FieldKey.hashCode` is cached (keyed_lens) and `KSObject` caches its
   per-field keys + field list (keyed_form_schema): `validateMap` ~15 µs →
   ~3 µs (JIT).
2. The generated `validate()` passes a **list** of field values
   (`_validationValues`) to `KSObject.validateValues` instead of building a
   `Map` via `toMap()` — no per-key hashing, O(1) access; nested objects /
   lists are still mapped.

#### AOT attribution of the keyed_form write path

`bin/attribution.dart` (`dart compile exe`, no asserts ≈ release) breaks down
one `form.field(ref).set(v)` at 100 flat fields. **Total ~3.9 µs** (was ~8.6 µs
with the `toMap()` path; JIT `flutter test` inflates ~2–3×):

| bucket | µs (list path) | µs (`toMap()` path) |
|---|--:|--:|
| `validateData` (list + walk / vs `toMap()` + walk) | **3.6** | 8.1 |
| `ref.set` → `copyWith` (construct the 100-field object) | 0.25 | 0.25 |
| `next == _value` guard (100-field compare) | 0.06 | 0.06 |
| `form.field(ref)` — `FieldHandle` allocation | 0.005 | 0.005 |

The whole write cost is now `validateData`; the immutable copy and the `==`
guard are free in AOT — earlier JIT-based guesses that pinned ~10 µs on the
object copy were wrong. Remaining on a flat form: the ~3.6 µs walk is
`_validationValues` (100 field reads + list) + 100 × `KSString.validate`.
`validateData(obj, scope)` trims that to ~3.0 µs — the list build and the
100-iteration filter loop are the floor for a flat schema; a nested/list
schema saves far more.

`build` stays cheap either way (generated `create()` ~3 µs vs reactive_forms
~800 µs).

> The µs tables here are **JIT `flutter test`** except where marked AOT. A
> uniform AOT comparison of all three widget libraries needs a Flutter
> **profile-mode** run on a device/emulator (`reactive_forms` imports
> `package:flutter/foundation`, `flutter_form_builder` is widget-only — neither
> can `dart compile exe`). See `integration_test/`.

#### AOT: keyed_form vs formz (both pure Dart)

`keyed_form` and `formz` are the two model libraries that *can* `dart compile
exe`. `bin/formz_aot.dart`, 100 flat fields, no asserts (≈ release):

| lib | setField | isValid read | isDirty read | per keystroke (write + 1 validity read) |
|---|--:|--:|--:|--:|
| keyed_form_gen — real `Bench100Schema` | 4.0 | ~0 (cached) | 0.06 | **~4.0** |
| keyed_form_gen — scoped | 3.5 | ~0 | 0.06 | **~3.5** |
| keyed_form — list-backed + hand resolver | 9.7 | ~0 | 0.38 | **~9.7** |
| **formz** | **0.21** | **0.94** | 0.10 | **~1.15** |

`formz` writes ~20–45× cheaper because it validates **nothing** on write; add
the one `isValid` read a reactive UI does per keystroke and it is still ~3×
under the tuned `keyed_form_gen` path on this trivial flat form. The catch is
structural, not this number:

* `formz`'s `isValid` is **O(N) and uncached** — it re-runs on *every* read,
  so a frame where M widgets check validity is M × O(N). `keyed_form` /
  `reactive_forms` validate once per write and cache. `formz` closes this gap
  per-input with `FormzInputErrorCacheMixin` when validators are expensive.
* the list-backed `keyed_form` stand-in's 9.7 µs is the hand resolver
  rebuilding all 100 `FieldKey`s every write; the generated path (cached keys
  + list values) is the 4.0 µs row and the one to compare against.
* the rules here are one `.trim().length` check per field. Real validators
  (regex, cross-field lookups) scale the O(N) read, not the O(1) write.

### Widget layer — one keystroke

Widget rebuilds triggered in the whole tree by typing into **one** field
(focus already settled), and the `pump` time it takes, by form size
(`integration_test/aot_benchmark_test.dart`, macOS debug — rebuild counts are
exact, pump times are debug-inflated but the *shape* holds):

| library | rebuilds (any N) | pump 100f | 250f | 500f | 1000f |
|---|--:|--:|--:|--:|--:|
| `keyed_form_flutter` | **41** | 17.0 ms | 17.2 | 17.4 | 30.9 |
| `reactive_forms` | **43** | 16.7 ms | 16.9 | 17.0 | 28.8 |
| `formz + flutter_bloc` | **44** | tracks the O(1) group¹ | | | |
| `flutter_form_builder` | **~24·N** | 70 ms | 116 | 228 | 485 (then hangs) |

¹ `formz + flutter_bloc` numbers so far are the JIT sweep
(`test/rebuild_benchmark_test.dart`): a flat **44 rebuilds** at 10/50/100/250f,
`pump` 6–12 ms — same shape as `keyed_form` / `reactive_forms`. Not yet run
through the on-device AOT sweep.

`keyed_form`, `reactive_forms` and `formz + flutter_bloc` all rebuild
**O(1)** — only the edited field's subtree (the ~42 constant is `EditableText`
+ overlay/gesture internals for that one field) — and their `pump` times
**track each other** at every N. keyed_form's O(N) listener fan-out
(~38 ns/field, above) is real but invisible: swamped by the framework's
per-keystroke cost; the jump at 1000f is laying out 1000 `TextField`s, not the
form library. `formz + flutter_bloc` has the exact same O(N)-cheap-work
shape — every field's `BlocSelector` re-runs its `selector` on each emit, but
only the one whose `FlatInput` changed by `==` rebuilds. A naïve whole-state
`BlocBuilder` around the column would instead be O(N) rebuilds.

`flutter_form_builder` is **O(N)**: every `FormBuilderField` (`AnimatedBuilder`
/ `Actions` / `_ActionsScope` …) rebuilds on every keystroke because they all
listen to the shared `FormBuilderState` — ~24·N rebuilds, quadratic-looking
`pump`, and it **times out** (>90 s) around 1000 fields.

The `keyed_form` design point that was flagged: **every** `KeyedFormField`
adds a listener to the whole controller, so a write fires N listener callbacks
(each re-reads its value + visible error and diffs). `reactive_forms` is O(1)
here (per-control streams); `keyed_form` is O(N).

**`bin/fanout.dart` (AOT) settles it — O(N) but the constant is tiny:**

| fields | 50 | 100 | 250 | 500 | 1000 | 2000 |
|---|--:|--:|--:|--:|--:|--:|
| µs / keystroke | 2.4 | 3.8 | 9.3 | 19 | 38 | 77 |

~38 ns per listener (flat), ~9× a bare `notifyListeners()` — so the per-field
*work* dominates, not the `ChangeNotifier` walk. At 1000 fields that is ~38 µs,
**~0.2 % of a 16.6 ms frame**; you would need tens of thousands of fields for
it to matter. **Not worth fixing** — real forms sit well under 200 fields
(<8 µs). If a pathological form ever needs it, the fix is a per-key
`Listenable` on the controller so a write notifies only the fields it touched.

## DX comparison

Build the same "tour builder" (nested object + dynamic list + cross-field rule
+ async server errors + dirty tracking + scroll-to-first-error) in each and
score:

| dimension | keyed_form | reactive_forms | flutter_form_builder | formz |
|---|---|---|---|---|
| source of truth | one immutable aggregate | tree of `FormControl`s | field widgets' `State` | hand-rolled state object |
| field addressing | typed `FieldRef` (generated) | `String` name | `String` name | direct typed field (`state.name`) |
| `field.set(wrongType)` | **compile error** | not checked (dynamic) | not checked (dynamic) | **compile error** |
| rename a model field | compile breaks at every use | silent runtime break | silent runtime break | compile breaks at every use |
| boilerplate per field | a schema line (generated ref) | a `FormControl` line | a `FormBuilderField` widget | a `FormzInput` subclass + error enum, by hand |
| when validation runs | on write, cached | on write, cached | on field change | **on every `isValid` read**, uncached |
| cross-field rule | resolver (built in) | group validator | manual | manual (outside `inputs`) |
| test without widgets | yes (pure Dart) | yes (model layer) | **no** | yes (pure Dart) |
| codegen (build_runner) | yes (`keyed_form_gen`) | no | no | no |
| dynamic list | `field(ref).list()` by id | `FormArray` by index | `FormBuilder` + manual list | manual `List<Input>` in state |
| server errors by path | `setServerErrorPaths` | manual | manual | manual (extra input per path) |
| selective rebuild | yes (O(1)) | yes (O(1)) | no (O(N)) | not its own — O(1) via `flutter_bloc` `BlocSelector`, O(N) via a naïve `BlocBuilder` |
| Flutter-free core | yes | no | no | yes |

`formz` and `keyed_form` land in the same quadrant — typed, immutable, pure
Dart — but `formz` stops at the single input: no path addressing, no list
handling, no cross-field rules, no rebuild story, and validation is a
recompute per read. `keyed_form` is roughly "`formz` plus the aggregate": the
resolver, the `FieldRef` paths, `field(ref).list()`, `scopeOf`, the
`ChangeNotifier`, and the Flutter binding.

Fill the qualitative half by having 2–3 devs unfamiliar with each library
implement one task, timed, with friction notes.

## Files

```
lib/scenario.dart            the one form shape + size sweep
lib/kf_form.dart             the list-backed keyed_form model/refs/resolver (any N)
lib/formz_model.dart         the FormzInput classes (shared by both formz harnesses)
lib/codegen/bench_schema.dart  100-field @keyedSchema; .kfg.dart is generated & committed
lib/codegen/bench_refs.dart    the 100 generated refs, indexable  (+ tool/gen_bench_schema.py)
lib/src/measure.dart         warmup + percentile timing helper + JSON report
lib/model/*_harness.dart     ModelHarness: build / setField / addRow / isValid / isDirty
                             (keyed_form ×2, keyed_form_gen ×2, reactive_forms, formz)
lib/widget/*_harness.dart    WidgetHarness: the form as real widgets, findable fields
                             (keyed_form_flutter, reactive_forms, flutter_form_builder,
                              formz+flutter_bloc)
bin/attribution.dart         AOT breakdown of the keyed_form write path (dart compile exe)
bin/fanout.dart              AOT sweep of the KeyedFormField listener fan-out cost
bin/formz_aot.dart           AOT keyed_form vs formz model layer (the two pure-Dart libs)
test/parity_test.dart          fairness gate
test/model_benchmark_test.dart          JIT, the size sweep
test/codegen_calibration_test.dart      JIT, list-backed vs a real generated model
test/rebuild_benchmark_test.dart        JIT, widget rebuilds per keystroke
integration_test/aot_benchmark_test.dart  --profile, 4-way, swept to 1000f (needs a scaffolded device)
```

To change the codegen schema size: `python3 tool/gen_bench_schema.py <N>` then
`dart run build_runner build`.

## Caveats

* The parameterised `keyed_form` model is an indexed `List<String>` with a
  hand-written resolver — read O(1), write one list copy, close to a generated
  class. The **real** codegen path (class + `toMap()`-based `validateData`) is
  measured separately in the calibration test and is ~3× slower per write; see
  that section.
* `reactive_forms` `updateValue` leaves a control pristine; the harness calls
  `markAsDirty()` after, mirroring what its widgets do.
* `formz` validates lazily, so its `setField` is a bare object copy and the
  cost surfaces in `isValid`. The harness models the idiomatic plain input
  (no `FormzInputErrorCacheMixin`). Cross-field validity and row-set dirtiness
  are computed in the harness — `formz` has no form-level concept.
* The `formz + flutter_bloc` widget row uses `BlocSelector` per field (the
  O(1) pattern). It measures `flutter_bloc`'s reactivity, not `formz` — but
  that pairing is `formz`'s documented one and the fair comparison to the
  other libraries' widget layers.
* `formz` itself is pure Dart (`meta` only); the widget harness adds
  `flutter_bloc` to the workspace lockfile.
* Debug-mode `flutter test` timings carry fake-async and assertion overhead —
  treat µs columns as ratios, not latencies. Rebuild counts are exact.
* Adding this package to the workspace pulls `reactive_forms` +
  `flutter_form_builder` into the shared lockfile. Drop it from the root
  `workspace:` list if that is unwanted.
