import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_code_block.dart';

class RecipesDoc extends StatelessComponent {
  const RecipesDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      div(id: 'recipes', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 04 · PRODUCTION RECIPES')]),
      h2(classes: 'docs-h2 display', [.text('Real-World Production Recipes')]),
      p([
        .text(
          'A collection of patterns for the thorniest problems you hit building a real Flutter app.',
        ),
      ]),

      // ---------------------------------------------------------------------
      // Recipe 1: Multi-Step Wizard
      // ---------------------------------------------------------------------
      div(id: 'recipe-wizard', classes: 'docs-anchor', []),
      h3(classes: 'docs-h3 display', [.text('Recipe 1: Multi-Step / Wizard Form')]),
      p([
        .text(
          "This isn't about Flutter's `Stepper` widget specifically — it already keeps every step's content mounted via `maintainState`/`AnimatedCrossFade`, so it doesn't lose state on its own. The problem shows up in the way most wizards actually get built: a hand-rolled step switcher, where `build()` returns a completely different widget subtree per step. Flutter then genuinely disposes the previous step's `State` (and any `TextEditingController` living inside it) the moment the step changes. ",
        ),
        .text(
          "With keyed_form, that's a non-issue: the draft lives in a single `KeyedFormController` at the parent State, completely outside whichever step widget is currently built. Swap the visible step as bluntly as you like — the data survives because it was never inside the disposed subtree to begin with:",
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/screens/wizard_screen.dart',
        language: 'dart',
        rawSnippet: '''class CheckoutWizardScreen extends StatefulWidget {
  const CheckoutWizardScreen({super.key});

  @override
  State<CheckoutWizardScreen> createState() => _CheckoutWizardScreenState();
}

class _CheckoutWizardScreenState extends State<CheckoutWizardScreen> {
  late final form = KeyedFormController<CheckoutSchema>(
    initialValue: CheckoutSchema.create(),
    mode: KeyedFormMode.onTouched,
    resolver: CheckoutSchema.validateData,
  );
  int _currentStep = 0;

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0) {
      form.touch(CheckoutFields.customerName.key);
      if (form.field(CheckoutFields.customerName).error == null) {
        setState(() => _currentStep++);
      }
    } else {
      form.handleSubmit(context, (data) async {
        await api.submitOrder(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedForm<CheckoutSchema>(
      controller: form,
      child: Column(
        children: [
          // A different widget subtree per step — the naive way genuinely
          // disposes the previous step's State when _currentStep changes.
          switch (_currentStep) {
            0 => KeyedFormField.text<CheckoutSchema>(
              field: CheckoutFields.customerName,
              builder: (context, f, textCtrl) => TextField(
                controller: textCtrl,
                enabled: !f.isReadOnly,
                onTapOutside: (_) => f.onBlur(),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  errorText: f.errorText,
                ),
              ),
            ),
            _ => KeyedFormField<CheckoutSchema, String>(
              field: CheckoutFields.paymentMethod,
              builder: (context, f) => DropdownButton<String>(
                value: f.value,
                items: const [
                  DropdownMenuItem(value: 'cod', child: Text('Cash on Delivery')),
                  DropdownMenuItem(value: 'card', child: Text('Credit Card')),
                ],
                onChanged: f.isReadOnly
                    ? null
                    : (val) {
                        if (val != null) {
                          f.onChanged(val);
                          f.onBlur();
                        }
                      },
              ),
            ),
          },
          ElevatedButton(
            onPressed: _next,
            child: Text(_currentStep == 0 ? 'Next' : 'Submit'),
          ),
        ],
      ),
    );
  }
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [
            .text('// A different subtree per step — keyed_form doesn\'t care that it gets disposed\n'),
          ]),
          span(classes: 'syntax-kw', [.text('switch ')]),
          .text('(_currentStep) {\n  '),
          span(classes: 'syntax-num', [.text('0')]),
          .text(' => '),
          span(classes: 'syntax-type', [.text('KeyedFormField')]),
          .text('.text<'),
          span(classes: 'syntax-type', [.text('CheckoutSchema')]),
          .text('>(\n    field: '),
          span(classes: 'syntax-type', [.text('CheckoutFields')]),
          .text('.customerName,\n    builder: (ctx, f, textCtrl) => '),
          span(classes: 'syntax-type', [.text('TextField')]),
          .text('(\n      controller: textCtrl,\n      decoration: InputDecoration(errorText: f.errorText),\n    ),\n  ),\n  _ => '),
          span(classes: 'syntax-type', [.text('KeyedFormField')]),
          .text('<'),
          span(classes: 'syntax-type', [.text('CheckoutSchema')]),
          .text(', '),
          span(classes: 'syntax-type', [.text('String')]),
          .text('>(\n    field: '),
          span(classes: 'syntax-type', [.text('CheckoutFields')]),
          .text('.paymentMethod,\n    builder: (ctx, f) => '),
          span(classes: 'syntax-type', [.text('DropdownButton')]),
          .text('(\n      value: f.value,\n      onChanged: (v) => v != null ? f.onChanged(v) : null,\n    ),\n  ),\n};'),
        ]),
      ),

      // ---------------------------------------------------------------------
      // Recipe 2: Mapping Backend Errors
      // ---------------------------------------------------------------------
      div(id: 'recipe-backend-errors', classes: 'docs-anchor', []),
      h3(classes: 'docs-h3 display', [.text('Recipe 2: Mapping Backend API Validation Errors')]),
      p([
        .text(
          'On submit, a backend typically returns a 422 error body shaped like: `{"errors": {"email": "Email already registered", "stops.[\'a1b2c3d4\'].city": "Invalid city"}}`. ',
        ),
        .text(
          "Instead of writing code to hunt down each matching input, `controller.setServerErrorPaths()` automatically resolves the server's wire-format path strings onto the right `FieldKey`s in the form: ",
        ),
      ]),
      p([
        .text(
          "Note the bracket syntax for the row: keyed_form addresses list rows by their stable `clientId`, never by array position, so the id segment must be that row's real `clientId` — typically because the client included it in the submitted payload and the server echoed it back. A bare `\"stops.0.city\"` parses as three plain field names, not a row lookup, and silently fails to match anything.",
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/services/api_error_handler.dart',
        language: 'dart',
        rawSnippet: '''try {
  await api.submitTour(form.value);
} on ApiException catch (e) {
  if (e.statusCode == 422) {
    // Resolves wire-format paths (like "stops.['<clientId>'].city") straight
    // onto the matching FieldKeys!
    form.setServerErrorPaths(Map<String, String>.from(e.responseBody['errors']));
    // Every invalid field on screen turns red with its message, instantly.
  }
}''',
        code: Component.fragment([
          span(classes: 'syntax-kw', [.text('try ')]),
          .text('{\n  '),
          span(classes: 'syntax-kw', [.text('await ')]),
          .text('api.submitTour(form.value);\n} '),
          span(classes: 'syntax-kw', [.text('on ')]),
          span(classes: 'syntax-type', [.text('ApiException')]),
          .text(' catch (e) {\n  '),
          span(classes: 'syntax-kw', [.text('if ')]),
          .text('(e.statusCode == '),
          span(classes: 'syntax-num', [.text('422')]),
          .text(') {\n    '),
          span(classes: 'syntax-comment', [.text('// Map the JSON error body straight onto the matching FieldKeys\n    ')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('setServerErrorPaths')]),
          .text('('),
          span(classes: 'syntax-type', [.text('Map<String, String>')]),
          .text(".from(e.responseBody['errors']));\n  }\n}"),
        ]),
      ),

      // ---------------------------------------------------------------------
      // Recipe 3: Cascading Dropdowns
      // ---------------------------------------------------------------------
      div(id: 'recipe-cascading', classes: 'docs-anchor', []),
      h3(classes: 'docs-h3 display', [.text('Recipe 3: Cascading Dropdowns')]),
      p([
        .text(
          'Handling a Country → State → City picker with `addRelation`. When the parent field changes, the child fields clear themselves and reload their options:',
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/controllers/location_relations.dart',
        language: 'dart',
        rawSnippet: '''late final VoidCallback _unsubscribeCountry;

@override
void initState() {
  super.initState();
  // On a new country: reset the state & city fields, load the new state list
  _unsubscribeCountry = form.addRelation(
    LocationFields.countryId,
    (countryId) => countryId,
    (newCountryId) {
      form.field(LocationFields.provinceId).set(null);
      form.field(LocationFields.districtId).set(null);
      if (newCountryId != null) {
        provinceBloc.loadProvinces(newCountryId);
      }
    },
  );
}

@override
void dispose() {
  _unsubscribeCountry();
  form.dispose();
  super.dispose();
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Auto-cascading reset and refetch on the parent field\n')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('addRelation')]),
          .text('(\n  '),
          span(classes: 'syntax-type', [.text('LocationFields')]),
          .text('.countryId,\n  (countryId) => countryId,\n  (newCountryId) {\n    form.'),
          span(classes: 'syntax-fn', [.text('field')]),
          .text('('),
          span(classes: 'syntax-type', [.text('LocationFields')]),
          .text('.provinceId).'),
          span(classes: 'syntax-fn', [.text('set')]),
          .text('(null);\n  },\n);'),
        ]),
      ),

      // ---------------------------------------------------------------------
      // Recipe 4: Custom UI Controls
      // ---------------------------------------------------------------------
      div(id: 'recipe-custom-controls', classes: 'docs-anchor', []),
      h3(classes: 'docs-h3 display', [.text('Recipe 4: Custom UI Controls (Switch, Stepper, Slider)')]),
      p([
        .text(
          "`KeyedFormField` isn't limited to `TextField`. Any Flutter widget can wire up through `KeyedFieldState<V>` (`f.value`, `f.onChanged`, `f.onBlur`, `f.isReadOnly`):",
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/widgets/custom_controls.dart',
        language: 'dart',
        rawSnippet: '''// 1. Wiring a SwitchListTile
KeyedFormField<SettingsSchema, bool>(
  field: SettingsFields.notificationsEnabled,
  builder: (context, f) => SwitchListTile(
    title: const Text('Enable push notifications'),
    value: f.value ?? false,
    onChanged: f.isReadOnly
        ? null
        : (val) {
            f.onChanged(val);
            f.onBlur();
          },
  ),
);

// 2. Wiring a stepper / quantity counter
KeyedFormField<OrderSchema, int>(
  field: OrderFields.guestCount,
  builder: (context, f) => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.remove),
        onPressed: (f.value ?? 1) > 1 && !f.isReadOnly
            ? () => f.onChanged((f.value ?? 1) - 1)
            : null,
      ),
      Text('\${f.value ?? 1} guests'),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: !f.isReadOnly
            ? () => f.onChanged((f.value ?? 1) + 1)
            : null,
      ),
    ],
  ),
);''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Any widget wires up the same way, through KeyedFieldState\n')]),
          span(classes: 'syntax-type', [.text('KeyedFormField')]),
          .text('<'),
          span(classes: 'syntax-type', [.text('SettingsSchema')]),
          .text(', '),
          span(classes: 'syntax-type', [.text('bool')]),
          .text('>(\n  field: '),
          span(classes: 'syntax-type', [.text('SettingsFields')]),
          .text('.notificationsEnabled,\n  builder: (context, f) => '),
          span(classes: 'syntax-type', [.text('SwitchListTile')]),
          .text(
            '(\n    value: f.value ?? false,\n    onChanged: f.isReadOnly ? null : (v) => f.onChanged(v),\n  ),\n);',
          ),
        ]),
      ),
    ]);
  }
}
