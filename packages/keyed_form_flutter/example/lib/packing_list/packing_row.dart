part of 'packing_list.dart';

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
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                labelText: 'Item',
                errorText: f.errorText,
              ),
            ),
          ),
        ),
        IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
      ],
    );
  }
}
