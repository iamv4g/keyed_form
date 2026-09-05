import 'package:flutter/widgets.dart';

/// Owns a [TextEditingController] two-way bound to an external string value
/// (typically `form.read(someTextField) ?? ''`), keeping the caret stable when
/// the value round-trips through the form controller.
///
/// Design-system agnostic: [builder] receives the controller and plugs it into
/// any text field (`TextField`, `ShadInput`, …). The wrapped field must NOT
/// pass its own `onChanged` back into the form — user edits are observed via
/// the controller and reported through [onChanged] here, which is what lets the
/// binding tell user edits apart from external updates.
///
/// External updates (undo, server patch, cross-field sync) overwrite the text
/// only when it actually differs from what the controller holds, clamping the
/// selection to the new length and dropping any IME composing region.
class KeyedTextBinding extends StatefulWidget {
  const KeyedTextBinding({
    required this.value,
    required this.onChanged,
    required this.builder,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final Widget Function(BuildContext context, TextEditingController controller)
  builder;

  @override
  State<KeyedTextBinding> createState() => _KeyedTextBindingState();
}

class _KeyedTextBindingState extends State<KeyedTextBinding> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  late String _lastReported = widget.value;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final text = _controller.text;
    if (text == _lastReported) return; // selection/composing-only change
    _lastReported = text;
    widget.onChanged(text);
  }

  @override
  void didUpdateWidget(covariant KeyedTextBinding oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value;
    if (next == oldWidget.value || next == _controller.text) return;
    _lastReported = next;
    _controller.value = TextEditingValue(
      text: next,
      selection: _clampSelection(_controller.selection, next.length),
    );
  }

  static TextSelection _clampSelection(TextSelection selection, int length) {
    if (!selection.isValid) return TextSelection.collapsed(offset: length);
    return TextSelection(
      baseOffset: selection.baseOffset.clamp(0, length),
      extentOffset: selection.extentOffset.clamp(0, length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
