import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:keyed_form/keyed_form.dart';

import '../../base_path.dart';
import '../../demos/login_schema.dart';
import 'observed_field.dart';

/// The hero's live proof of the headline: two fields on one
/// `KeyedFormController`, each with its own rebuild counter. Typing moves
/// only the edited field's counter, while the controller itself notifies
/// on every keystroke.
@client
class HeroLoginDemo extends StatefulComponent {
  const HeroLoginDemo({super.key});

  @override
  State<HeroLoginDemo> createState() => _HeroLoginDemoState();
}

class _HeroLoginDemoState extends State<HeroLoginDemo> {
  late final form = KeyedFormController<LoginSchema>(
    initialValue: LoginSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: LoginSchema.validateData,
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
    return div(classes: 'hero-demo blueprint-box', [
      div(classes: 'playground-panel-title mono', [.text('// LIVE — type into a field')]),
      ObservedField<LoginSchema, String>(
        form: form,
        field: LoginFields.email,
        label: 'Email',
        builder: (value, onChange, onBlur) => input<String>(
          type: InputType.email,
          classes: 'playground-input',
          attributes: {'autocomplete': 'off', 'placeholder': 'you@example.com'},
          value: value ?? '',
          onInput: onChange,
          events: {'blur': (_) => onBlur()},
        ),
      ),
      ObservedField<LoginSchema, String>(
        form: form,
        field: LoginFields.password,
        label: 'Password',
        builder: (value, onChange, onBlur) => input<String>(
          type: InputType.password,
          classes: 'playground-input',
          attributes: {'autocomplete': 'off'},
          value: value ?? '',
          onInput: onChange,
          events: {'blur': (_) => onBlur()},
        ),
      ),
      div(classes: 'hero-demo-footer mono', [
        span([
          .text('Controller notified '),
          span(classes: 'text-cyan', [.text('$_notifications×')]),
          .text(' · nothing leaves this page'),
        ]),
        a(href: '$siteBasePath/playground', [.text('Open full playground →')]),
      ]),
    ]);
  }
}
