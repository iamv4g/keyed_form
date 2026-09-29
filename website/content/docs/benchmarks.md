---
title: Benchmarks
description: Reproduce model and widget measurements and understand their limits.
---

The benchmark harness compares equivalent form operations across form sizes. Run it from the repository with `cd benchmark && ./tool/run.sh`.

<Note>

Measurements use Flutter tests in JIT debug mode, not an AOT release build. Rebuild counts are exact; microsecond timings are directional and depend on the test machine.

</Note>

## Model latency by form size

Median microseconds per operation for a flat form with required and minimum-length validation. `keyed_form` uses a list-backed model with a hand-written resolver in this comparison:

| Operation | Architecture | 10 fields | 50 fields | 100 fields | 250 fields |
|---|---|---:|---:|---:|---:|
| `setField` | keyed_form | 11.00 | 5.00 | 9.00 | 22.00 |
| `setField` | String-Keyed Reactive | 25.00 | 20.00 | 24.00 | 37.00 |
| `setField` | Sealed-State Validator | 0.00 | 0.00 | 0.00 | 0.00 |
| `isValid` | keyed_form | 0.004 | 0.004 | 0.004 | 0.004 |
| `isValid` | String-Keyed Reactive | 0.004 | 0.004 | 0.004 | 0.004 |
| `isValid` | Sealed-State Validator | 0.15 | 0.62 | 1.21 | 3.04 |

The Sealed-State Validator defers validation until `isValid` is read, so its write cost is near zero while each validity read grows with form size. The other two validate on write and cache the result, keeping `isValid` flat. These timings are directional JIT debug measurements, not release latency.

## Model latency with a dynamic list

This case has 20 flat fields and a 100-row list with two fields per row, plus a cross-field constraint that the sum of nights does not exceed `maxNights`:

| Architecture | Commit an edit (µs) | `isDirty` check (µs) | `isValid` check (µs) | Add + remove row (µs) |
|---|---:|---:|---:|---:|
| keyed_form | 2.00 | 0.01 | 0.00 | 18.00 |
| String-Keyed Reactive | 30.00 | 0.00 | 0.00 | 108.00 |
| Sealed-State Validator | 0.00 | 0.02 | 2.85 | 0.00 |

## Widget rebuilds per keystroke

Counts are whole-tree widget rebuilds after typing one character into one field, once focus has settled. These are exact counts from the harness:

| Architecture | 10 fields | 50 fields | 100 fields | 250 fields |
|---|---:|---:|---:|---:|
| keyed_form_flutter | 44 | 44 | 44 | 44 |
| String-Keyed Reactive | 45 | 45 | 45 | 45 |
| Sealed-State Validator | 44 | 44 | 44 | 44 |
| Declarative Builder | 261 | 1,221 | 2,421 | 6,021 |

The first three architectures rebuild a constant number of widgets in this harness. Declarative Builder rebuilds scale with the field count and the harness starts timing out around 1,000 fields. Rebuild counts are exact; microsecond timings vary with the test machine.

## Capability matrix

<CapabilityMatrix />

The benchmark source and test setup are available in [`benchmark/README.md`](https://github.com/iamv4g/keyed_form/blob/main/benchmark/README.md).
