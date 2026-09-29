---
title: Scroll to the first error
description: Reveal and focus the first invalid field, including rows not yet built in a virtualized list.
---

`handleSubmit(context, onValid)` reveals the first invalid field when it is mounted. In a lazy list, an off-screen row may not have an anchor yet, so first scroll to the row's section and then ask the registry to reveal it.

## Two-phase reveal

1. **Coarse scroll:** map the first visible error key to its section, then scroll until that section is built.
2. **Fine reveal:** after the next frame, call `KeyedFieldRegistry.revealFirst` to use the field anchor for precise positioning and focus.

Keep section keys by row `clientId`, not by index, so the mapping survives list reorder.

```dart
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

For forms without lazy sections, use `handleSubmit` directly; it handles the reveal and focus flow for mounted fields.
