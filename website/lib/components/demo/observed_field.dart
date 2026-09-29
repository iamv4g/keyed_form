import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:keyed_form/keyed_form.dart';

/// Wraps one field: reads it through the real `FieldHandle` API, and only
/// calls `setState` (bumping its own rebuild counter) when this field's own
/// value or error actually changed — the same isolation `KeyedFormField`
/// gives you in Flutter, hand-rolled here for plain HTML.
class ObservedField<Root, V> extends StatefulComponent {
  const ObservedField({
    required this.form,
    required this.field,
    required this.label,
    required this.builder,
    this.showRebuilds = true,
    super.key,
  });

  final KeyedFormController<Root> form;
  final FieldRef<Root, V> field;
  final String label;
  final Component Function(V? value, ValueChanged<V> onChange, VoidCallback onBlur) builder;

  final bool showRebuilds;

  @override
  State<ObservedField<Root, V>> createState() => _ObservedFieldState<Root, V>();
}

class _ObservedFieldState<Root, V> extends State<ObservedField<Root, V>> {
  int _rebuilds = 0;
  late V? _lastValue = _handle.value;
  late String? _lastError = _handle.error;

  FieldHandle<Root, V> get _handle => component.form.field(component.field);

  @override
  void initState() {
    super.initState();
    component.form.addListener(_check);
  }

  @override
  void didUpdateComponent(covariant ObservedField<Root, V> oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.form != component.form) {
      oldComponent.form.removeListener(_check);
      component.form.addListener(_check);
    }
  }

  void _check() {
    final value = _handle.value;
    final error = _handle.error;
    if (value == _lastValue && error == _lastError) return;
    _rebuilds++;
    if (mounted) {
      setState(() {
        _lastValue = value;
        _lastError = error;
      });
    }
  }

  @override
  void dispose() {
    component.form.removeListener(_check);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'playground-field', [
      div(classes: 'playground-field-label mono', [
        .text(component.label),
        if (component.showRebuilds) span(classes: 'playground-rebuild-badge mono', [.text('rebuilds: $_rebuilds')]),
      ]),
      component.builder(
        _lastValue,
        (v) => _handle.set(v),
        () => _handle.touch(),
      ),
      if (_lastError != null) div(classes: 'playground-field-error mono', [.text(_lastError!)]),
    ]);
  }
}

/// Rebuilds on *every* controller notification, no matter what — the
/// deliberate contrast to [ObservedField]'s scoped reads.
class ObserverPanel<Root> extends StatefulComponent {
  const ObserverPanel({required this.form, required this.title, required this.render});

  final KeyedFormController<Root> form;
  final String title;
  final String Function(KeyedFormController<Root> form) render;

  @override
  State<ObserverPanel<Root>> createState() => _ObserverPanelState<Root>();
}

class _ObserverPanelState<Root> extends State<ObserverPanel<Root>> {
  @override
  void initState() {
    super.initState();
    component.form.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    component.form.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'playground-panel blueprint-box', [
      div(classes: 'playground-panel-title mono', [.text(component.title)]),
      pre(classes: 'playground-panel-body mono', [.text(component.render(component.form))]),
    ]);
  }
}
