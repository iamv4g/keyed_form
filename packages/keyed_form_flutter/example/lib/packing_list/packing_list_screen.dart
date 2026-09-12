import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../fields.dart';
import '../widgets/demo_note.dart';
import '../widgets/demo_scaffold.dart';
import 'packing_schema.dart';

/// `KeyedFieldList` bound straight to the list field — no hand-rolled row-id
/// tracking (compare `tour_builder`, which tracks it by hand because it also
/// needs the id sequence for its own scroll-anchor bookkeeping).
class PackingListScreen extends StatefulWidget {
  const PackingListScreen({super.key});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  final form = KeyedFormController<PackingSchema>(
    initialValue: PackingSchema.create(
      items: [
        PackingItemSchema.create(label: 'Passport'),
        PackingItemSchema.create(label: 'Charger'),
        PackingItemSchema.create(label: 'Rain jacket'),
      ],
    ),
    mode: KeyedFormMode.onTouched,
    resolver: PackingSchema.validateData,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Packing list',
      maxWidth: 480,
      child: KeyedForm<PackingSchema>(
        controller: form,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: DemoNote(
                'Every row op below — add, insert after, reorder, check '
                'off, remove — goes through the KeyedFieldList builder\'s '
                'own list, and the widget rebuilds only when the row set '
                'itself changes.',
              ),
            ),
            Expanded(
              child: KeyedFieldList<PackingSchema, PackingItemSchema>(
                field: PackingFields.items,
                builder: (context, items, list) => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _PackingRow(
                        key: ValueKey(items[i].clientId),
                        fields: PackingFields.item((item: items[i].clientId)),
                        canMoveUp: i > 0,
                        canMoveDown: i < items.length - 1,
                        onMoveUp: () => list.move(i, i - 1),
                        onMoveDown: () => list.move(i, i + 1),
                        onInsertAfter: () => list.insertAfter(
                          items[i].clientId,
                          PackingItemSchema.create(),
                        ),
                        onRemove: items.length > 1
                            ? () => list.removeById(items[i].clientId)
                            : null,
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => list.append(PackingItemSchema.create()),
                      icon: const Icon(Icons.add),
                      label: const Text('Add item'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackingRow extends StatelessWidget {
  const _PackingRow({
    super.key,
    required this.fields,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onInsertAfter,
    required this.onRemove,
  });

  final ItemFieldRefs fields;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onInsertAfter;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      KeyedFormField<PackingSchema, bool>(
        field: fields.packed,
        anchor: false,
        builder: (context, f) => Checkbox(
          value: f.value ?? false,
          onChanged: (v) => f.onChanged(v ?? false),
        ),
      ),
      Expanded(
        child: KeyedText<PackingSchema>(field: fields.label, label: 'Item'),
      ),
      IconButton(
        onPressed: canMoveUp ? onMoveUp : null,
        icon: const Icon(Icons.arrow_upward),
      ),
      IconButton(
        onPressed: canMoveDown ? onMoveDown : null,
        icon: const Icon(Icons.arrow_downward),
      ),
      IconButton(
        tooltip: 'Insert a new item after this one',
        onPressed: onInsertAfter,
        icon: const Icon(Icons.playlist_add),
      ),
      IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
    ],
  );
}
