import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:keyed_form/keyed_form.dart';

import '../../playground/playground_schema.dart';
import '../demo/observed_field.dart';

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
        ObservedField<PlaygroundSchema, String>(
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
        ObservedField<PlaygroundSchema, String>(
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
        ObservedField<PlaygroundSchema, int?>(
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
        ObservedField<PlaygroundSchema, bool>(
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
        ObservedField<PlaygroundSchema, PlanTier>(
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
        ObserverPanel<PlaygroundSchema>(
          form: form,
          title: '// WATCH — form.value.toMap()',
          render: (f) => _jsonEncoder.convert(f.value.toMap()),
        ),
        ObserverPanel<PlaygroundSchema>(
          form: form,
          title: '// ERRORS — form.visibleErrorKeys',
          render: (f) => f.visibleErrorKeys.isEmpty
              ? '{}'
              : _jsonEncoder.convert({
                  for (final key in f.visibleErrorKeys) key.toPath(): f.errors.byKey(key),
                }),
        ),
        ObserverPanel<PlaygroundSchema>(
          form: form,
          title: '// TOUCHED — form.touched',
          render: (f) => f.touched.isEmpty ? '[]' : _jsonEncoder.convert([for (final key in f.touched) key.toPath()]),
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
