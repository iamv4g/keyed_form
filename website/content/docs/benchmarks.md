---
title: Benchmarks
description: Reproduce model and widget measurements and understand their limits.
---

The benchmark harness compares equivalent form operations across form sizes. Run it from the repository with `cd benchmark && ./tool/run.sh`.

<Note>

Measurements use Flutter tests in JIT debug mode, not an AOT release build. Rebuild counts are exact; microsecond timings are directional and depend on the test machine.

</Note>

## Model latency by form size

Median microseconds per operation for a flat form with required and minimum-length validation:

| Operation | 10 fields | 50 fields | 100 fields | 250 fields |
|---|---:|---:|---:|---:|
| `setField` | 11 | 5 | 9 | 22 |
| `isValid` | 0.004 | 0.004 | 0.004 | 0.004 |

## Widget rebuilds per keystroke

The harness records 44 rebuilds for `keyed_form_flutter` at 10, 50, 100, and 250 fields. The measured count stays flat as fields are added.

## Capability matrix

<CapabilityMatrix />

The benchmark source and test setup are available in [`benchmark/README.md`](https://github.com/iamv4g/keyed_form/blob/main/benchmark/README.md).
