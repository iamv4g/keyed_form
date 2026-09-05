import 'package:flutter/widgets.dart';
import 'package:keyed_form/keyed_form.dart';

/// Maps [FieldKey]s to live field positions so a form can scroll to (and focus)
/// a field it only knows by identity — the "first validation error" case.
/// Fields opt in by wrapping themselves in a [KeyedFieldAnchor].
///
/// Create one registry per form (alongside the [KeyedFormController]) and pass it to
/// [KeyedFormScope]; the registry holds no resources and needs no dispose.
class KeyedFieldRegistry {
  final Map<FieldKey, _KeyedFieldAnchorState> _anchors = {};

  /// Scrolls the field registered under [key] into view and focuses it if its
  /// anchor carries a focus node. Returns whether an anchor was found — false
  /// means the field isn't currently built (e.g. its row was removed).
  bool reveal(
    FieldKey key, {
    Duration duration = const Duration(milliseconds: 300),
    double alignment = 0.1,
  }) {
    final anchor = _anchors[key];
    if (anchor == null || !anchor.mounted) return false;
    Scrollable.ensureVisible(
      anchor.context,
      alignment: alignment,
      duration: duration,
      curve: Curves.easeInOut,
    );
    anchor.widget.focusNode?.requestFocus();
    return true;
  }

  /// Reveals the first key with a live anchor. Pass [KeyedFormController.errors]`
  /// .keys` or [KeyedFormController.visibleErrorKeys]: the validation walk builds
  /// the map in document order and Dart maps preserve insertion order, so
  /// "first" is the topmost failing field.
  bool revealFirst(
    Iterable<FieldKey> keys, {
    Duration duration = const Duration(milliseconds: 300),
    double alignment = 0.1,
  }) {
    for (final key in keys) {
      if (reveal(key, duration: duration, alignment: alignment)) return true;
    }
    return false;
  }
}

/// Registers [child]'s position under [fieldKey] for the lifetime of the
/// widget. Zero visual footprint. [KeyedFormField] wraps its builder output in
/// one automatically; use it directly only for non-field scroll targets.
class KeyedFieldAnchor extends StatefulWidget {
  const KeyedFieldAnchor({
    required this.registry,
    required this.fieldKey,
    required this.child,
    this.focusNode,
    super.key,
  });

  final KeyedFieldRegistry registry;
  final FieldKey fieldKey;

  /// Optional: focused after the scroll when this anchor is revealed. Share the
  /// same node with the wrapped text field to land the caret there.
  final FocusNode? focusNode;

  final Widget child;

  @override
  State<KeyedFieldAnchor> createState() => _KeyedFieldAnchorState();
}

class _KeyedFieldAnchorState extends State<KeyedFieldAnchor> {
  @override
  void initState() {
    super.initState();
    widget.registry._anchors[widget.fieldKey] = this;
  }

  @override
  void didUpdateWidget(covariant KeyedFieldAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registry != widget.registry ||
        oldWidget.fieldKey != widget.fieldKey) {
      _unregisterFrom(oldWidget);
      widget.registry._anchors[widget.fieldKey] = this;
    }
  }

  @override
  void dispose() {
    _unregisterFrom(widget);
    super.dispose();
  }

  /// Only removes the entry if it still points at this state — a sibling anchor
  /// that re-registered the same key must not be evicted.
  void _unregisterFrom(KeyedFieldAnchor anchor) {
    if (identical(anchor.registry._anchors[anchor.fieldKey], this)) {
      anchor.registry._anchors.remove(anchor.fieldKey);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
