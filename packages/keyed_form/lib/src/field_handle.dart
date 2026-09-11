import 'dart:async';

import 'package:keyed_form_core/keyed_form_core.dart';

import 'keyed_form_controller.dart';
import 'keyed_form_list.dart';

/// A per-field facade over [KeyedFormController], addressed by a [FieldRef] and
/// obtained with `form.field(ref)` — the `useController()` of this family. It
/// reads, writes, dirty-checks and touches one field, and (for a list field)
/// hands back a [KeyedFormList] row editor.
///
/// Binding the field's value type [V] here — where inference takes it from
/// `ref` alone — is what lets [set] / [update] reject a wrongly-typed value at
/// compile time. Calling [KeyedFormController.setField] directly lets inference
/// widen [V] to a common supertype of the field and the argument, so the
/// mismatch would only surface as a runtime `TypeError`.
///
/// ```dart
/// form.field(InvoiceFields.customerEmail).set('ada@example.com');
/// form.field(InvoiceFields.customerEmail).error; // null until touched / submitted
/// form.field(InvoiceFields.lineItems).list().append(LineItem.create());
/// ```
class FieldHandle<Root, V> {
  FieldHandle._(this._form, this._ref);

  final KeyedFormController<Root> _form;
  final FieldRef<Root, V> _ref;

  /// Identity of the addressed field.
  FieldKey get key => _ref.key;

  /// The current value, or `null` when the path no longer resolves.
  V? get value => _ref.getOrNull(_form.value);

  /// The visible validation error, gated by the controller's mode; `null` when
  /// there is none or it is not visible yet.
  String? get error => _form.visibleErrorFor(_ref);

  /// Whether this field differs from the seeded baseline.
  bool get dirty => _form.differs(_ref);

  /// Whether this field is currently mid-async-validation.
  bool get isValidating => _form.isValidating(_ref.key);

  /// Writes [value] to the field (no-op if the path no longer resolves or the
  /// draft is unchanged).
  void set(V value) => _form.setField(_ref, value);

  /// Reads the field, applies [transform], writes it back — one revalidation,
  /// one notification.
  void update(V Function(V current) transform) =>
      _form.updateField(_ref, transform);

  /// Marks the field touched and re-validates the subtree it belongs to.
  void touch() => _form.touch(_ref.key);

  /// Runs [check] as this field's async validation — see
  /// [KeyedFormController.validateFieldAsync].
  Future<void> validateAsync(FutureOr<String?> Function() check) =>
      _form.validateFieldAsync(_ref.key, check);
}

/// `form.field(ref)` — the entry point to [FieldHandle].
extension KeyedFormFieldAccess<Root> on KeyedFormController<Root> {
  /// A statically-typed handle to one field of the draft. Prefer this over
  /// [setField] / [updateField] / [list] for everyday field access.
  FieldHandle<Root, V> field<V>(FieldRef<Root, V> ref) =>
      FieldHandle._(this, ref);
}

/// Row editing for a list field — available only when [V] is
/// `List<Item extends KeyedRow>`.
extension FieldHandleList<Root, Item extends KeyedRow>
    on FieldHandle<Root, List<Item>> {
  /// A by-id row editor (`append` / `insert` / `removeById` / `move` /
  /// `updateById`, …) — the `useFieldArray` of this family.
  KeyedFormList<Root, Item> list() => KeyedFormList.forController(_form, _ref);

  /// The row keys whose row differs from the seeded baseline (rows absent from
  /// the baseline count as dirty).
  Iterable<FieldKey> dirtyRows() => _form.dirtyRows(_ref);
}
