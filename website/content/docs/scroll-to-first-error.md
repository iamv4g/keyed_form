---
title: Scroll to the first error
description: Reveal and focus the first invalid field, including rows not yet built in a virtualized list.
---

`handleSubmit(context, onValid)` reveals the first invalid field when it is mounted. In a lazy list, an off-screen row may not have an anchor yet, so first scroll to the row's section and then ask the registry to reveal it.

## Two-phase reveal

1. **Coarse scroll:** map the first visible error key to its section using the row's `clientId`, then scroll until that section is built. In a sliver list, the target section's `RenderSliver.constraints.precedingScrollExtent` gives its logical offset. Walk the viewport toward that offset until the target has been laid out.
2. **Fine reveal:** after the next frame, call `KeyedFieldRegistry.revealFirst` to use the field anchor for precise positioning and focus.

Keep section keys by row `clientId`, not by index, so the mapping survives list reorder.

```dart
// Pseudocode: sectionForKey and jumpToSection are app-specific. For a lazy
// sliver, jumpToSection resolves the section's precedingScrollExtent and
// advances the scroll position until that section is laid out.
Future<void> revealFirstError(BuildContext context) async {
  final keys = form.visibleErrorKeys.toList();
  if (keys.isEmpty) return;

  await jumpToSection(sectionForKey(keys.first));
  if (!context.mounted) return;
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;

  KeyedForm.registryOf<TourSchema>(context).revealFirst(
    form.visibleErrorKeys,
    alignment: 0.5,
  );
}
```

The coarse pass is needed because an unbuilt row has no field anchor. Once the target is built, wait for `WidgetsBinding.instance.endOfFrame` before asking the registry to reveal and focus the exact field.

For forms without lazy sections, use `handleSubmit` directly; it handles the reveal and focus flow for mounted fields.
