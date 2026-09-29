---
title: FAQ
description: Common setup and form state questions.
---

## Why was no generated file created?

Check that the schema library has `@keyedSchema` and a matching `part 'name.kfg.dart';` declaration, then run `dart run build_runner build -d`.

## How do I load an existing record and reset to it?

Call `controller.seed(apiData)` after loading. This makes the fetched value the clean baseline; `reset()` returns to it.

## How do I reveal the first invalid field?

In Flutter, submit with `form.handleSubmit(context, onValid)`. It reveals and focuses the first invalid field that is mounted. For an off-screen lazy row, use the [two-phase scroll recipe](docs/scroll-to-first-error).

## Why does a nested field have a nullable value?

A list row or nullable object can disappear while a reference still exists. Its `FieldRef` therefore resolves to no value rather than writing through a stale path. Root fields that always exist use `StrictFieldRef`.
