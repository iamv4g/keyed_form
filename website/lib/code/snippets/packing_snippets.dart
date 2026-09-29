/// Adapted from `example/lib/packing_list/` to drag with dnd_kit_flutter.
/// Not compiled here — re-check with `flutter analyze` in the example.
abstract final class PackingSnippets {
  static const schema = r'''@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'packing_schema.kfg.dart';

final _packingSchema = ks.object({
  'items': ks
      .list(
        ks.object(className: 'PackingItemSchema', {
          'label': ks.string(error: .text('Give it a name')).min(1),
          'packed': ks.boolean().defaultTo(false),
        }),
      )
      .min(1, error: .text('Add at least one item')),
});''';

  static const list = r'''import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import 'packing_schema.dart';

part 'packing_row.dart';

class PackingList extends StatelessWidget {
  const PackingList({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyedFieldList<PackingSchema, PackingItemSchema>(
      field: PackingFields.items,
      builder: (context, items, list) => SortableScope(
        itemIds: [for (final item in items) DndId(item.clientId)],
        onMove: (d) => list.move(d.fromIndex, d.toIndex),
        child: Column(
          children: [
            for (final item in items)
              SortableItem(
                key: ValueKey(item.clientId),
                id: DndId(item.clientId),
                child: _PackingRow(
                  fields: PackingFields.item(itemClientId: item.clientId),
                  onRemove: () => list.removeById(item.clientId),
                ),
              ),
            TextButton.icon(
              onPressed: () => list.append(PackingItemSchema.create()),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
          ],
        ),
      ),
    );
  }
}''';

  static const row = r'''part of 'packing_list.dart';

class _PackingRow extends StatelessWidget {
  const _PackingRow({required this.fields, required this.onRemove});

  final ItemFieldRefs fields;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DndDragHandle(child: Icon(Icons.drag_indicator)),
        KeyedFormField<PackingSchema, bool>(
          field: fields.packed,
          anchor: false,
          builder: (context, f) => Checkbox(
            value: f.value ?? false,
            onChanged: (v) => f.onChanged(v ?? false),
          ),
        ),
        Expanded(
          child: KeyedFormField.text<PackingSchema>(
            field: fields.label,
            builder: (context, f, controller) => TextField(
              controller: controller,
              onTapOutside: (_) => f.onBlur(),
              decoration: InputDecoration(errorText: f.errorText),
            ),
          ),
        ),
        IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
      ],
    );
  }
}''';
}
