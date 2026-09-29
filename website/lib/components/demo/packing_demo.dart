import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:keyed_form/keyed_form.dart';
import 'package:universal_web/web.dart' as web;

import '../../demos/packing_schema.dart';

/// Rows keyed by `clientId`, reordered by dragging a handle.
@client
class PackingDemo extends StatefulComponent {
  const PackingDemo({super.key});

  @override
  State<PackingDemo> createState() => _PackingDemoState();
}

class _PackingDemoState extends State<PackingDemo> {
  late final form = KeyedFormController<PackingSchema>(
    initialValue: PackingSchema(
      items: [
        for (final label in const ['Passport', 'Charger', 'Sunscreen']) PackingItemSchema.create(label: label),
      ],
    ),
    mode: KeyedFormMode.onChange,
    resolver: PackingSchema.validateData,
  );

  late final list = form.field(PackingFields.items).list();

  @override
  void initState() {
    super.initState();
    form.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  String _name(DndId id) {
    final label = list.byId(id.value)?.label ?? '';
    return label.isEmpty ? 'untitled item' : label;
  }

  late final _announcements = DndAnnouncements(
    onDragStart: (active) => 'Picked up ${_name(active)}.',
    onDragOver: (active, over) =>
        over == null ? '${_name(active)} is not over a row.' : '${_name(active)} is over ${_name(over)}.',
    onDragEnd: (active, over) => 'Dropped ${_name(active)}.',
    onDragCancel: (active) => 'Cancelled moving ${_name(active)}.',
  );

  void _move(SortableMoveDetails d) {
    final id = list.items[d.fromIndex].clientId;
    list.move(d.fromIndex, d.toIndex);
    if (!kIsWeb) return;
    // Moving the row's DOM node drops focus; give it back to the handle.
    Future(() {
      final active = web.document.activeElement;
      if (active != null && active != web.document.body) return;
      final handle = web.document.querySelector('[data-row="$id"] [aria-roledescription="drag handle"]');
      (handle as web.HTMLElement?)?.focus();
    });
  }

  @override
  void dispose() {
    form.removeListener(_rebuild);
    form.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final items = list.items;
    return div(classes: 'pack-demo', [
      div(classes: 'pack-box blueprint-box', [
        div(classes: 'playground-panel-title mono', [.text('// RUNNING — drag ⠿, then type')]),
        SortableScope(
          strategy: SortableStrategies.dropOnOver,
          offsetResolver: SortableOffsets.verticalList,
          itemIds: [for (final item in items) DndId(item.clientId)],
          onMove: _move,
          child: div(classes: 'pack-list', [
            for (final item in items)
              SortableItem(
                key: ValueKey(item.clientId),
                id: DndId(item.clientId),
                // Handle-only drags, so touch needs no long-press.
                constraint: const DndSensorActivationConstraint(distance: 4),
                label: item.label.isEmpty ? 'Untitled item' : item.label,
                description: 'Press space on the handle to lift, arrow keys to move, space to drop.',
                builder: (context, drag, child) {
                  final offset = drag.offset;
                  return div(
                    classes: drag.isActive || drag.isDragging ? 'pack-slot lifted' : 'pack-slot',
                    styles: offset == DndPoint.zero
                        ? null
                        : Styles(raw: {'transform': 'translate(${offset.x}px, ${offset.y}px)'}),
                    [child],
                  );
                },
                child: _PackingRow(
                  form: form,
                  clientId: item.clientId,
                  canRemove: items.length > 1,
                  onRemove: () => list.removeById(item.clientId),
                ),
              ),
            DndDragOverlay(
              builder: (context, overlay) {
                final label = list.byId(overlay.activeId.value)?.label ?? '';
                return div(classes: 'pack-row pack-row-overlay', [
                  span(classes: 'pack-handle', [.text('⠿')]),
                  span(classes: 'pack-overlay-label', [.text(label.isEmpty ? 'Untitled item' : label)]),
                ]);
              },
            ),
            DndLiveRegion(announcements: _announcements),
          ]),
        ),
        button(
          type: ButtonType.button,
          classes: 'pack-add mono',
          onClick: () => list.append(PackingItemSchema.create()),
          [.text('+ Add item')],
        ),
      ]),
      div(classes: 'playground-panel blueprint-box', [
        div(classes: 'playground-panel-title mono', [.text('// ROWS — index · clientId · label')]),
        pre(classes: 'playground-panel-body mono', [
          .text(
            [
              for (var i = 0; i < items.length; i++)
                '$i  ${items[i].clientId.substring(0, 8)}…  ${items[i].label.isEmpty ? '—' : items[i].label}',
            ].join('\n'),
          ),
        ]),
      ]),
    ]);
  }
}

class _PackingRow extends StatelessComponent {
  const _PackingRow({required this.form, required this.clientId, required this.canRemove, required this.onRemove});

  final KeyedFormController<PackingSchema> form;
  final String clientId;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Component build(BuildContext context) {
    final fields = PackingFields.item(itemClientId: clientId);
    final label = form.field(fields.label);
    final packed = form.field(fields.packed);
    return div(
      classes: 'pack-row',
      attributes: {'data-row': clientId},
      [
        DndDragHandle(
          label: 'Reorder',
          child: span(classes: 'pack-handle', attributes: {'aria-hidden': 'true'}, [.text('⠿')]),
        ),
        input<bool>(
          type: InputType.checkbox,
          attributes: {'aria-label': 'Packed'},
          checked: packed.value ?? false,
          onChange: (v) => packed.set(v),
        ),
        div(classes: 'pack-field', [
          input<String>(
            type: InputType.text,
            classes: 'playground-input',
            attributes: {'aria-label': 'Item', 'autocomplete': 'off'},
            value: label.value ?? '',
            onInput: (v) => label.set(v),
          ),
          if (label.error case final error?) div(classes: 'playground-field-error mono', [.text(error)]),
        ]),
        button(
          type: ButtonType.button,
          classes: 'pack-remove',
          attributes: {'aria-label': 'Remove item', 'title': 'Remove'},
          disabled: !canRemove,
          onClick: onRemove,
          [.text('✕')],
        ),
      ],
    );
  }
}
