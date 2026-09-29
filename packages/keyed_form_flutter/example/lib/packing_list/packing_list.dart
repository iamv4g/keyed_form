import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import 'packing_schema.dart';

part 'packing_row.dart';

class PackingList extends StatefulWidget {
  const PackingList({super.key});

  @override
  State<PackingList> createState() => _PackingListState();
}

class _PackingListState extends State<PackingList> {
  final dnd = DndController();

  @override
  void dispose() {
    dnd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedFieldList<PackingSchema, PackingItemSchema>(
      field: PackingFields.items,
      builder: (context, items, list) => Stack(
        children: [
          SortableScope(
            controller: dnd,
            strategy: SortableStrategies.dropOnOver,
            offsetResolver: SortableOffsets.verticalList,
            itemIds: [for (final item in items) DndId(item.clientId)],
            onMove: (d) => list.move(d.fromIndex, d.toIndex),
            child: Column(
              children: [
                for (final item in items)
                  SortableItem(
                    key: ValueKey(item.clientId),
                    id: DndId(item.clientId),
                    activationConstraint: const DndSensorActivationConstraint(
                      distance: 4,
                    ),
                    builder: (context, drag, child) => AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: Matrix4.translationValues(0, drag.offset.y, 0),
                      child: Opacity(
                        opacity: drag.isDragging ? 0 : 1,
                        child: child,
                      ),
                    ),
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
          DndDragOverlay(
            controller: dnd,
            builder: (context, drag) => Material(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.drag_indicator),
                title: Text(list.byId(drag.activeId.value)?.label ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
