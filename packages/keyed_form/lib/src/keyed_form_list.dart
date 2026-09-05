import 'package:keyed_lens/keyed_lens.dart';

import 'keyed_form_controller.dart';

/// A by-id editor for one list field of a [KeyedFormController]'s draft — the
/// `useFieldArray` of this family.
///
/// Every mutation is applied immutably and pushed back through
/// [KeyedFormController.updateField], so validation and change notification happen
/// exactly once per call. Rows are matched by [KeyedRow.clientId]; indices are
/// accepted only where react-hook-form accepts them too (positional
/// insert/move/swap).
///
/// Obtain one with `form.list(SomeFields.rows(ref))`.
class KeyedFormList<Root, Item extends KeyedRow> {
  KeyedFormList.forController(this._controller, this._field);

  final KeyedFormController<Root> _controller;
  final FieldRef<Root, List<Item>> _field;

  /// The current rows (empty when the list's path no longer resolves).
  List<Item> get items => _field.getOrNull(_controller.value) ?? const [];

  int get length => items.length;

  Item? byId(String clientId) {
    for (final item in items) {
      if (item.clientId == clientId) return item;
    }
    return null;
  }

  int indexOf(String clientId) =>
      items.indexWhere((item) => item.clientId == clientId);

  void append(Item item) => _write((list) => [...list, item]);

  void prepend(Item item) => _write((list) => [item, ...list]);

  void insert(int index, Item item) =>
      _write((list) => [...list]..insert(index.clamp(0, list.length), item));

  /// Inserts [item] right after the row with [clientId]; no-op if that row is
  /// gone.
  void insertAfter(String clientId, Item item) => _write((list) {
    final at = list.indexWhere((e) => e.clientId == clientId);
    if (at < 0) return list;
    return [...list]..insert(at + 1, item);
  });

  /// Removes row [index] and returns it, or `null` if out of range.
  Item? removeAt(int index) {
    final list = items;
    if (index < 0 || index >= list.length) return null;
    final removed = list[index];
    _write((current) => [...current]..removeAt(index));
    return removed;
  }

  /// Removes the row with [clientId] and returns it, or `null` if not found.
  Item? removeById(String clientId) {
    final removed = byId(clientId);
    if (removed == null) return null;
    _write(
      (list) => [
        for (final item in list)
          if (item.clientId != clientId) item,
      ],
    );
    return removed;
  }

  void move(int from, int to) => _write((list) {
    if (from < 0 || from >= list.length || to < 0 || to >= list.length) {
      return list;
    }
    final next = [...list];
    next.insert(to, next.removeAt(from));
    return next;
  });

  void swap(int a, int b) => _write((list) {
    if (a < 0 || a >= list.length || b < 0 || b >= list.length) return list;
    final next = [...list];
    next[a] = list[b];
    next[b] = list[a];
    return next;
  });

  void updateAt(int index, Item Function(Item current) transform) =>
      _write((list) {
        if (index < 0 || index >= list.length) return list;
        return [...list]..[index] = transform(list[index]);
      });

  void updateById(String clientId, Item Function(Item current) transform) =>
      _write(
        (list) => [
          for (final item in list)
            if (item.clientId == clientId) transform(item) else item,
        ],
      );

  void _write(List<Item> Function(List<Item> current) transform) =>
      _controller.mutateList(_field, transform);
}
