import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:keyed_form/keyed_form.dart';

import '../../playground/playground_schema.dart';

// toMap() puts raw enum values (like PlanTier) straight into the map for
// in-Dart use — JsonEncoder needs telling how to turn those into JSON itself.
final _jsonEncoder = JsonEncoder.withIndent(
  '  ',
  (Object? value) => value is Enum ? value.name : value,
);

/// The live demo: a real `KeyedFormController<PlaygroundSchema>` (pure Dart,
/// no Flutter) driving plain HTML inputs, with a per-field rebuild counter
/// next to each one and three observer panels showing the whole draft,
/// errors, and touched state update in real time.
@client
class PlaygroundDemo extends StatefulComponent {
  const PlaygroundDemo({super.key});

  @override
  State<PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<PlaygroundDemo> {
  // onTouched (the controller's own default): errors and the Touched panel
  // stay quiet while typing and only react once a field is blurred — the
  // point of the Touched panel would be lost under onChange, which touches
  // on every keystroke.
  late final form = KeyedFormController<PlaygroundSchema>(
    initialValue: PlaygroundSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: PlaygroundSchema.validateData,
  );

  int _notifications = 0;

  @override
  void initState() {
    super.initState();
    form.addListener(_onFormChange);
  }

  void _onFormChange() {
    _notifications++;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    form.removeListener(_onFormChange);
    form.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'playground-grid', [
      div(classes: 'playground-form blueprint-box', [
        div(classes: 'playground-panel-title mono', [.text('// LIVE FORM — type into a field')]),
        _ObservedField<String>(
          form: form,
          field: PlaygroundFields.name,
          label: 'Name',
          builder: (value, onChange, onBlur) => input<String>(
            type: InputType.text,
            classes: 'playground-input',
            value: value ?? '',
            onInput: onChange,
            events: {'blur': (_) => onBlur()},
          ),
        ),
        _ObservedField<String>(
          form: form,
          field: PlaygroundFields.email,
          label: 'Email',
          builder: (value, onChange, onBlur) => input<String>(
            type: InputType.email,
            classes: 'playground-input',
            value: value ?? '',
            onInput: onChange,
            events: {'blur': (_) => onBlur()},
          ),
        ),
        _ObservedField<int?>(
          form: form,
          field: PlaygroundFields.age,
          label: 'Age',
          builder: (value, onChange, onBlur) => input<num>(
            type: InputType.number,
            classes: 'playground-input',
            value: value?.toString() ?? '',
            onInput: (v) => onChange(v.toInt()),
            events: {'blur': (_) => onBlur()},
          ),
        ),
        _ObservedField<bool>(
          form: form,
          field: PlaygroundFields.newsletter,
          label: 'Subscribe to the newsletter',
          builder: (value, onChange, onBlur) => input<bool>(
            type: InputType.checkbox,
            checked: value ?? false,
            onChange: (v) {
              onChange(v);
              onBlur();
            },
          ),
        ),
        _ObservedField<PlanTier>(
          form: form,
          field: PlaygroundFields.plan,
          label: 'Plan',
          builder: (value, onChange, onBlur) => div(classes: 'playground-segmented', [
            for (final tier in PlanTier.values)
              button(
                type: ButtonType.button,
                classes: value == tier ? 'playground-segment active' : 'playground-segment',
                onClick: () {
                  onChange(tier);
                  onBlur();
                },
                [.text(tier.name)],
              ),
          ]),
        ),
      ]),
      div(classes: 'playground-observers', [
        _ObserverPanel(
          form: form,
          title: '// WATCH — form.value.toMap()',
          render: (f) => _jsonEncoder.convert(f.value.toMap()),
        ),
        _ObserverPanel(
          form: form,
          title: '// ERRORS — form.visibleErrorKeys',
          render: (f) => f.visibleErrorKeys.isEmpty
              ? '{}'
              : _jsonEncoder.convert({
                  for (final key in f.visibleErrorKeys) key.toPath(): f.errors.byKey(key),
                }),
        ),
        _ObserverPanel(
          form: form,
          title: '// TOUCHED — form.touched',
          render: (f) => f.touched.isEmpty
              ? '[]'
              : _jsonEncoder.convert([for (final key in f.touched) key.toPath()]),
        ),
        div(classes: 'playground-notifications mono', [
          .text('Total controller notifications: '),
          span(classes: 'text-red', [.text('$_notifications')]),
          .text(' — every keystroke notifies once, but only the field(s) whose slice actually changed rebuild above.'),
        ]),
      ]),
    ]);
  }
}

/// Wraps one field: reads it through the real `FieldHandle` API, and only
/// calls `setState` (bumping its own rebuild counter) when this field's own
/// value or error actually changed — the same isolation `KeyedFormField`
/// gives you in Flutter, hand-rolled here for plain HTML.
class _ObservedField<V> extends StatefulComponent {
  const _ObservedField({
    required this.form,
    required this.field,
    required this.label,
    required this.builder,
    super.key,
  });

  final KeyedFormController<PlaygroundSchema> form;
  final FieldRef<PlaygroundSchema, V> field;
  final String label;
  final Component Function(V? value, ValueChanged<V> onChange, VoidCallback onBlur) builder;

  @override
  State<_ObservedField<V>> createState() => _ObservedFieldState<V>();
}

class _ObservedFieldState<V> extends State<_ObservedField<V>> {
  int _rebuilds = 0;
  late V? _lastValue = _handle.value;
  late String? _lastError = _handle.error;

  FieldHandle<PlaygroundSchema, V> get _handle => component.form.field(component.field);

  @override
  void initState() {
    super.initState();
    component.form.addListener(_check);
  }

  @override
  void didUpdateComponent(covariant _ObservedField<V> oldComponent) {
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
        span(classes: 'playground-rebuild-badge mono', [.text('rebuilds: $_rebuilds')]),
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
/// deliberate contrast to [_ObservedField]'s scoped reads.
class _ObserverPanel extends StatefulComponent {
  const _ObserverPanel({required this.form, required this.title, required this.render});

  final KeyedFormController<PlaygroundSchema> form;
  final String title;
  final String Function(KeyedFormController<PlaygroundSchema> form) render;

  @override
  State<_ObserverPanel> createState() => _ObserverPanelState();
}

class _ObserverPanelState extends State<_ObserverPanel> {
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
