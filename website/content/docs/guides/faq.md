---
title: FAQ
description: Answers to common schema generation, controller reset, field reference, and error reveal questions.
---

## Why was no generated file created?

Check that the library has `@keyedSchema` and a matching `part 'name.kfg.dart';` declaration, then run `dart run build_runner build -d`. The declared part filename must match the source filename. See [Code generation](docs/schema/code-generation) for the supported schema shape and troubleshooting steps.

## How do I load an existing record and reset to it?

Call `controller.seed(apiData)` after loading. That value becomes the clean baseline, and `reset()` restores it. See [Controller and lifecycle](docs/form-state/controller) for the behavior of `seed`, `reset`, and dirty comparisons.

## Why does a nested field reference have a nullable value?

A list row or nullable object can disappear while a reference still exists, so a `FieldRef` can stop resolving instead of writing through a stale path. Root fields that always exist use `StrictFieldRef`. See [Field handles](docs/form-state/field-handles) and [Objects and collections](docs/schema/composition).

## How do I reveal the first invalid field?

In Flutter, call `handleSubmit` with a context below `KeyedForm`; it reveals and focuses the first invalid field with a mounted anchor. A lazy list may not have built an off-screen row yet, so first scroll to its section and then reveal the field. See [Form scope and context](docs/flutter/form-context) and [Submit and scroll to error](docs/flutter/scroll-to-first-error).

## Why is an error not visible immediately?

Validation errors and visible errors are distinct. Visibility follows the controller's configured mode and interaction state; `reveal` or submission can make errors visible without changing the underlying rule result. See [Validation and visibility](docs/form-state/validation). For remote checks, distinguish [async field validation](docs/form-state/async-validation) from schema refinement rules in [Schema](docs/schema/refinements).
