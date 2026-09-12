import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_text_binding.dart';
import 'keyed_field_registry.dart';
import 'keyed_form.dart';

/// Everything a field widget needs, computed from the ambient [KeyedFormController]
/// for one [FieldRef] — the analogue of react-hook-form's `useController`
/// result.
///
/// [KeyedFormField] wraps the builder output in a [KeyedFieldAnchor] itself
/// (unless `anchor: false`), so a field widget no longer has to forward a
/// registry or field key to opt into scroll-to-error. Wire [onBlur] to the
/// wrapped control's focus-lost for touch-on-blur.
@immutable
class KeyedFieldState<V> {
  const KeyedFieldState({
    required this.value,
    required this.onChanged,
    required this.onBlur,
    required this.errorText,
    required this.fieldKey,
    required this.isValidating,
    required this.isFailedValidation,
  });

  /// The field's current value, or `null` when its path no longer resolves.
  final V? value;

  /// Writes a new value into the form (revalidates, notifies).
  final ValueChanged<V> onChanged;

  /// Marks the field touched — wire to the wrapped control's focus-lost, or
  /// call it directly for a control that commits on close (a picker dialog).
  final VoidCallback onBlur;

  /// The visible, translated error, or `null` — render this directly.
  final String? errorText;

  /// This field's identity — handy for a `ValueKey` on the built control. The
  /// anchor is registered under it automatically; a builder does not need to.
  final FieldKey fieldKey;

  /// Whether this field is currently mid-async-validation — render a spinner
  /// alongside the control while this is `true`. Set it around your own
  /// async check with `form.field(ref).validateAsync(...)` (or the
  /// lower-level `form.setFieldValidating(key, ...)`).
  final bool isValidating;

  /// Whether this field's last `validateAsync` call ended in a technical
  /// failure (it threw, or exceeded its timeout) rather than a verdict about
  /// the value — render a retry affordance from this, distinct from
  /// [errorText]. See `KeyedFormController.isFailedValidation`.
  final bool isFailedValidation;
}

/// Binds one [FieldRef] to the ambient [KeyedFormController] (via [KeyedForm]) and
/// rebuilds **only** when that field's value or visible error changes — a
/// write to a sibling field does not rebuild this one.
///
/// The builder output is wrapped in a [KeyedFieldAnchor] (registered under the
/// field's key against the scope's [KeyedFieldRegistry]) so revealing the first
/// validation error can scroll to it. Pass `anchor: false` for a field that is
/// never a scroll target.
///
/// ```dart
/// KeyedFormField<InvoiceForm, String>(
///   field: InvoiceFields.lineItem(ref).description,
///   builder: (context, f) => TextInput(
///     value: f.value ?? '',
///     onChanged: f.onChanged,
///     onTouched: f.onBlur,
///     errorText: f.errorText,
///     label: Text('Description'),
///   ),
/// )
/// ```
class KeyedFormField<Root, V> extends StatefulWidget {
  const KeyedFormField({
    required this.field,
    required this.builder,
    this.anchor = true,
    super.key,
  });

  final FieldRef<Root, V> field;
  final Widget Function(BuildContext context, KeyedFieldState<V> state) builder;

  /// Register a [KeyedFieldAnchor] under the field's key so the form can scroll
  /// to it. `false` opts out — for a field that can never hold the first error.
  final bool anchor;

  /// A [KeyedFormField] for a `String` field that bundles a [KeyedTextBinding],
  /// so the builder gets a ready `TextEditingController`.
  static Widget text<Root>({
    Key? key,
    required FieldRef<Root, String> field,
    bool anchor = true,
    required Widget Function(
      BuildContext context,
      KeyedFieldState<String> state,
      TextEditingController controller,
    )
    builder,
  }) => KeyedFormField<Root, String>(
    key: key,
    field: field,
    anchor: anchor,
    builder: (context, state) => KeyedTextBinding(
      value: state.value ?? '',
      onChanged: state.onChanged,
      builder: (context, controller) => builder(context, state, controller),
    ),
  );

  @override
  State<KeyedFormField<Root, V>> createState() =>
      _KeyedFormFieldState<Root, V>();
}

class _KeyedFormFieldState<Root, V> extends State<KeyedFormField<Root, V>> {
  KeyedFormController<Root>? _controller;
  KeyedFieldRegistry? _registry;
  KeyedErrorTranslator _translate = (_, error) => error;

  Object? _lastValue;
  String? _lastError;
  bool _hasField = true;
  bool _lastValidating = false;
  bool _lastFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = KeyedForm.controllerOf<Root>(context);
    _registry = KeyedForm.registryOf<Root>(context);
    _translate = KeyedForm.translateErrorOf<Root>(context);
    if (!identical(_controller, controller)) {
      _controller?.removeListener(_onFormChange);
      _controller = controller;
      _controller!.addListener(_onFormChange);
    }
    _readSnapshot();
  }

  @override
  void didUpdateWidget(covariant KeyedFormField<Root, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.key != widget.field.key) _readSnapshot();
  }

  void _onFormChange() {
    final prevValue = _lastValue;
    final prevError = _lastError;
    final prevHasField = _hasField;
    final prevValidating = _lastValidating;
    final prevFailed = _lastFailed;
    _readSnapshot();
    if (prevValue != _lastValue ||
        prevError != _lastError ||
        prevHasField != _hasField ||
        prevValidating != _lastValidating ||
        prevFailed != _lastFailed) {
      if (mounted) setState(() {});
    }
  }

  void _readSnapshot() {
    final controller = _controller;
    if (controller == null) return;
    _hasField = widget.field.existsIn(controller.value);
    _lastValue = widget.field.getOrNull(controller.value);
    final raw = controller.visibleError(widget.field.key);
    _lastError = raw == null ? null : _translate(context, raw);
    _lastValidating = controller.isValidating(widget.field.key);
    _lastFailed = controller.isFailedValidation(widget.field.key);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onFormChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasField) return const SizedBox.shrink();
    final controller = _controller!;
    final child = widget.builder(
      context,
      KeyedFieldState<V>(
        value: _lastValue as V?,
        onChanged: (v) => controller.field(widget.field).set(v),
        onBlur: () => controller.touch(widget.field.key),
        errorText: _lastError,
        fieldKey: widget.field.key,
        isValidating: _lastValidating,
        isFailedValidation: _lastFailed,
      ),
    );
    if (!widget.anchor) return child;
    return KeyedFieldAnchor(
      registry: _registry!,
      fieldKey: widget.field.key,
      child: child,
    );
  }
}
