import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

import 'keyed_field_registry.dart';
import 'keyed_form.dart';
import 'keyed_text_binding.dart';

/// Everything a field widget needs, computed from the ambient [KeyedFormController]
/// for one [FieldRef] — the analogue of react-hook-form's `useController`
/// result.
///
/// [KeyedFormField] wraps the builder output in a non-focusable [Focus]
/// boundary and, unless `anchor: false`, a [KeyedFieldAnchor]. Focus loss marks
/// the field touched automatically; set `autoDetectBlur: false` for controls
/// that report their own logical blur through [KeyedFieldState.onBlur].
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
    required this.isReadOnly,
  });

  /// The field's current value, or `null` when its path no longer resolves.
  final V? value;

  /// Writes a new value into the form (revalidates, notifies).
  final ValueChanged<V> onChanged;

  /// Marks the field touched. Called automatically when focus leaves the
  /// field's focus subtree unless [KeyedFormField.autoDetectBlur] is disabled.
  ///
  /// Call it directly for controls with a separate logical focus lifecycle,
  /// such as a picker that remains open in an overlay. The callback is inert
  /// after this field is disposed or its binding no longer resolves.
  final VoidCallback onBlur;

  /// The visible, translated error, or `null` — render this directly.
  final String? errorText;

  /// This field's identity — handy for a `ValueKey` on the built control. The
  /// anchor is registered under it automatically; a builder does not need to.
  final FieldKey fieldKey;

  /// Whether this field is currently mid-async-validation — render a spinner
  /// alongside the control while this is `true`. Async rules are configured
  /// through the controller's `asyncValidators`.
  final bool isValidating;

  /// Whether this field's latest configured async rule ended in a technical
  /// failure (threw or timed out) rather than a value verdict — render a retry
  /// affordance from this, distinct from [errorText].
  final bool isFailedValidation;

  /// Whether this field is frozen against writes — pass `enabled: !isReadOnly`
  /// to the wrapped Material widget to grey it out. [onChanged] stays safe to
  /// wire unconditionally: the controller already no-ops a frozen write. See
  /// `KeyedFormController.markReadOnly`.
  final bool isReadOnly;
}

/// Binds one [FieldRef] to the ambient [KeyedFormController] (via [KeyedForm]) and
/// rebuilds **only** when that field's value or visible error changes — a
/// write to a sibling field does not rebuild this one.
///
/// Focus leaving the builder output's widget subtree calls
/// [KeyedFieldState.onBlur] by default. Set [autoDetectBlur] to `false` when a
/// control's logical focus extends outside that subtree, and call `onBlur`
/// explicitly at the logical boundary.
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
    this.autoDetectBlur = true,
    super.key,
  });

  final FieldRef<Root, V> field;
  final Widget Function(BuildContext context, KeyedFieldState<V> state) builder;

  /// Register a [KeyedFieldAnchor] under the field's key so the form can scroll
  /// to it. `false` opts out — for a field that can never hold the first error.
  final bool anchor;

  /// Whether to call [KeyedFieldState.onBlur] when focus leaves this field's
  /// widget subtree. Disable for controls that report logical blur manually.
  final bool autoDetectBlur;

  /// A [KeyedFormField] for a `String` field that bundles a [KeyedTextBinding],
  /// so the builder gets a ready `TextEditingController`.
  static Widget text<Root>({
    Key? key,
    required FieldRef<Root, String> field,
    bool anchor = true,
    bool autoDetectBlur = true,
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
    autoDetectBlur: autoDetectBlur,
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
  late final VoidCallback _onBlur = _handleBlur;
  bool _hasSubtreeFocus = false;
  bool _lastValidating = false;
  bool _lastFailed = false;
  bool _lastReadOnly = false;

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
    final prevReadOnly = _lastReadOnly;
    _readSnapshot();
    if (prevValue != _lastValue ||
        prevError != _lastError ||
        prevHasField != _hasField ||
        prevValidating != _lastValidating ||
        prevFailed != _lastFailed ||
        prevReadOnly != _lastReadOnly) {
      if (mounted) setState(() {});
    }
  }

  void _handleBlur() {
    if (!mounted) return;
    final controller = _controller;
    if (controller == null || !widget.field.existsIn(controller.value)) return;
    controller.touch(widget.field.key);
  }

  void _handleFocusChange(bool hasFocus) {
    final wasFocused = _hasSubtreeFocus;
    _hasSubtreeFocus = hasFocus;
    if (wasFocused && !hasFocus && widget.autoDetectBlur && _hasField) {
      _onBlur();
    }
  }

  void _readSnapshot() {
    final controller = _controller;
    if (controller == null) return;
    _hasField = widget.field.existsIn(controller.value);
    if (!_hasField) _hasSubtreeFocus = false;
    _lastValue = widget.field.getOrNull(controller.value);
    final raw = controller.visibleError(widget.field.key);
    _lastError = raw == null ? null : _translate(context, raw);
    _lastValidating = controller.isValidating(widget.field.key);
    _lastFailed = controller.isFailedValidation(widget.field.key);
    _lastReadOnly = controller.isReadOnly(widget.field.key);
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
        onBlur: _onBlur,
        errorText: _lastError,
        fieldKey: widget.field.key,
        isValidating: _lastValidating,
        isFailedValidation: _lastFailed,
        isReadOnly: _lastReadOnly,
      ),
    );
    final focusBoundary = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _handleFocusChange,
      child: child,
    );
    if (!widget.anchor) return focusBoundary;
    return KeyedFieldAnchor(
      registry: _registry!,
      fieldKey: widget.field.key,
      child: focusBoundary,
    );
  }
}
