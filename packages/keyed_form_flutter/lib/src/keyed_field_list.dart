import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_form_scope.dart';

/// Binds one list field to the ambient [KeyedFormController] and rebuilds only when
/// the row set changes (add / remove / reorder) — edits *within* a row are the
/// job of the [KeyedFormField]s inside it. The analogue of react-hook-form's
/// `useFieldArray`.
///
/// ```dart
/// KeyedFieldList<InvoiceForm, LineItem>(
///   field: InvoiceFields.lineItems,
///   builder: (context, items, list) => Column(children: [
///     for (final item in items)
///       LineItemCard(key: ValueKey(item.clientId), id: item.clientId),
///     AddButton(onPressed: () => list.append(LineItem.create())),
///   ]),
/// )
/// ```
class KeyedFieldList<Root, Item extends KeyedRow> extends StatefulWidget {
  const KeyedFieldList({required this.field, required this.builder, super.key});

  final FieldRef<Root, List<Item>> field;
  final Widget Function(
    BuildContext context,
    List<Item> items,
    KeyedFormList<Root, Item> list,
  )
  builder;

  @override
  State<KeyedFieldList<Root, Item>> createState() =>
      _KeyedFieldListState<Root, Item>();
}

class _KeyedFieldListState<Root, Item extends KeyedRow>
    extends State<KeyedFieldList<Root, Item>> {
  KeyedFormController<Root>? _controller;
  List<String> _lastIds = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = KeyedFormScope.controllerOf<Root>(context);
    if (!identical(_controller, controller)) {
      _controller?.removeListener(_onFormChange);
      _controller = controller;
      _controller!.addListener(_onFormChange);
    }
    _lastIds = _currentIds();
  }

  void _onFormChange() {
    final ids = _currentIds();
    if (!_sameOrder(ids, _lastIds)) {
      _lastIds = ids;
      if (mounted) setState(() {});
    }
  }

  List<String> _currentIds() => [for (final item in _items()) item.clientId];

  List<Item> _items() => widget.field.getOrNull(_controller!.value) ?? const [];

  static bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller?.removeListener(_onFormChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _items(), _controller!.field(widget.field).list());
}
