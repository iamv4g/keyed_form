---
title: Submit and scroll to error
description: Validate on submit and reveal mounted invalid fields, with a two-phase pattern for lazy sections.
---

`form.handleSubmit(context, onValid)` runs a fresh validation before saving.
Value errors call `onInvalid` when supplied; otherwise the registry reveals
the first visible value error. Blocking technical failures call
`onValidationUnavailable`; without a custom callback the registry reveals the
failed-check fields. Providing either callback replaces the default reveal
behavior for that outcome. The `BuildContext` must be below the matching
`KeyedForm` (use a descendant builder context, as shown in
[form scope](docs/flutter/form-context)).

`KeyedFormField` registers an anchor automatically unless created with
`anchor: false`. Custom callbacks are useful when an app needs to scroll a
lazy section before asking the registry to reveal a mounted child.
`KeyedFieldRegistry.revealFirst` can only reveal mounted anchors: an unbuilt
`ListView.builder` row cannot be focused precisely.

## Two-phase reveal for lazy sections

For a virtualized tour builder, first map the first visible error key to the section/row identified by its stable `clientId`, then scroll coarsely until that section has been laid out. After the next frame, call the registry's `revealFirst` for precise positioning and focus. Keep section identity tied to row IDs rather than list indexes so reordering does not redirect the reveal.

The repository has a concrete implementation in [`tour_builder_screen.dart`](https://github.com/iamv4g/keyed_form/blob/main/packages/keyed_form_flutter/example/lib/tour_builder/tour_builder_screen.dart): `_revealFirstError` coordinates invalid keys, `_sectionForKey` finds a section, and `_jumpToSection` advances the lazy viewport before registry reveal. This is app-owned coarse scrolling; `handleSubmit` covers the mounted-anchor phase, not arbitrary lazy-list navigation. See [virtualized lists](docs/flutter/long-lists).
