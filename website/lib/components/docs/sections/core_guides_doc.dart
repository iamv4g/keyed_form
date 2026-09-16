import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_code_block.dart';

class CoreGuidesDoc extends StatelessComponent {
  const CoreGuidesDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      // ---------------------------------------------------------------------
      // 2.0 Package Architecture
      // ---------------------------------------------------------------------
      div(id: 'package-architecture', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono', [.text('// 02.0 · PACKAGE ARCHITECTURE')]),
      h2(classes: 'docs-h2 display', [.text('Six Packages, One Clean Dependency Chain')]),
      p(classes: 'docs-lead', [
        .text(
          'keyed_form is a pub workspace of 6 packages arranged in a linear dependency chain — the core is 100% pure Dart, with no Flutter dependency until the final widget layer, so the entire form logic is unit-testable in CI without pumping a single widget.',
        ),
      ]),
      ul(classes: 'docs-list', [
        li([
          code([.text('keyed_lens')]),
          .text(
            ' — Pure Dart, 0 dependencies. Provides the general-purpose optics toolkit (Lens, AffineLens, Prism, FieldKey) used internally to solve nested immutable data updates.',
          ),
        ]),
        li([
          code([.text('keyed_form_core')]),
          .text(
            " — Depends on keyed_lens. Defines the form tier's shared vocabulary: FieldRef, StrictFieldRef, FieldErrors, @keyedSchema.",
          ),
        ]),
        li([
          code([.text('keyed_form_schema')]),
          .text(' — Depends on keyed_form_core. The declarative schema & validation DSL (`ks.*`). Pure Dart.'),
        ]),
        li([
          code([.text('keyed_form_gen')]),
          .text(
            ' — Dev-time codegen via build_runner: turns a declarative schema into an immutable model, typed field refs, and a validator function.',
          ),
        ]),
        li([
          code([.text('keyed_form')]),
          .text(' — The pure-Dart state controller (KeyedFormController) with scoped listener bindings.'),
        ]),
        li([
          code([.text('keyed_form_flutter')]),
          .text(
            ' — The Flutter binding layer: KeyedForm, KeyedFormField, KeyedFieldList, KeyedTextBinding.',
          ),
        ]),
      ]),

      // ---------------------------------------------------------------------
      // 2.1 Controller Lifecycle
      // ---------------------------------------------------------------------
      div(id: 'controller-lifecycle', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 02.1 · CONTROLLER LIFECYCLE')]),
      h2(classes: 'docs-h2 display', [.text('Form Controller & State Lifecycle')]),
      p([
        .text(
          "`KeyedFormController<Root>` is the brain that manages form state. It's a pure-Dart `ChangeNotifier` (from `package:listen`), fully independent of the Flutter widget tree, holding the form's immutable data object.",
        ),
      ]),

      const DocsCodeBlock(
        title: 'controller_lifecycle.dart',
        language: 'dart',
        rawSnippet: '''// 1. Initialize the controller with the generated Schema and resolver
final form = KeyedFormController<LoginSchema>(
  initialValue: LoginSchema.create(),
  mode: KeyedFormMode.onChange,
  resolver: LoginSchema.validateData,
);

// 2. Set a clean baseline with seed() — use this when loading initial data from an API
form.seed(userFromApi);
print(form.isDirty); // false

// 3. The user edits an input, changing the draft
form.field(LoginFields.email).set('alice@example.com');
print(form.isDirty); // true
print(form.differs(LoginFields.email)); // true

// 4. Restore the original
form.reset();
print(form.isDirty); // false

// 5. Submit with full automatic validation
final success = await form.submit(
  (draft) async {
    await api.login(draft);
  },
  onInvalid: (errorKeys) {
    print('Invalid fields: \$errorKeys');
  },
);''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// 1. Initialize the controller\n')]),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('form = '),
          span(classes: 'syntax-type', [.text('KeyedFormController<LoginSchema>')]),
          .text('(\n  initialValue: '),
          span(classes: 'syntax-type', [.text('LoginSchema')]),
          .text('.create(),\n  mode: '),
          span(classes: 'syntax-type', [.text('KeyedFormMode')]),
          .text('.onChange,\n  resolver: '),
          span(classes: 'syntax-type', [.text('LoginSchema')]),
          .text('.validateData,\n);\n\n'),
          span(classes: 'syntax-comment', [.text('// 2. Set a clean baseline with seed() when loading from the API\n')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('seed')]),
          .text('(userFromApi);\nprint(form.isDirty); '),
          span(classes: 'syntax-comment', [.text('// false\n\n')]),
          span(classes: 'syntax-comment', [.text('// 3. Edit data through a FieldHandle\n')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('field')]),
          .text('(LoginFields.email).'),
          span(classes: 'syntax-fn', [.text('set')]),
          .text('('),
          span(classes: 'syntax-str', [.text("'alice@example.com'")]),
          .text(');\nprint(form.isDirty); '),
          span(classes: 'syntax-comment', [.text('// true\n\n')]),
          span(classes: 'syntax-comment', [.text('// 4. Submit safely\n')]),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('success = '),
          span(classes: 'syntax-kw', [.text('await ')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('submit')]),
          .text('(\n  (draft) '),
          span(classes: 'syntax-kw', [.text('async ')]),
          .text('{\n    '),
          span(classes: 'syntax-kw', [.text('await ')]),
          .text('api.login(draft);\n  },\n);'),
        ]),
      ),

      // ---------------------------------------------------------------------
      // 2.2 Field Handles & Mutations
      // ---------------------------------------------------------------------
      div(id: 'field-handles', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 02.2 · FIELD HANDLES')]),
      h2(classes: 'docs-h2 display', [.text('Field Handles & Targeted O(1) Rebuilds')]),
      p([
        .text(
          'Access any field in the form through `form.field(ref)`. The `FieldHandle<Root, V>` object gives you reading, writing, dirty-checking, and error-state management — all without letting a type mismatch slip through:',
        ),
      ]),

      ul(classes: 'docs-list', [
        li([
          code([.text('handle.value')]),
          .text(' — Reads the current value with its exact static type `V?`. No casting needed.'),
        ]),
        li([
          code([.text('handle.set(newValue)')]),
          .text(
            ' — Writes a new value, type-checked at compile time. Only the widget observing this field rebuilds (O(1)).',
          ),
        ]),
        li([
          code([.text('handle.update((curr) => ...)')]),
          .text(' — Transforms the value atomically (read-transform-write) in a single notification cycle.'),
        ]),
        li([
          code([.text('handle.touch()')]),
          .text(" — Marks the field touched, triggering error visibility per the controller's mode."),
        ]),
        li([
          code([.text('handle.error')]),
          .text(' — Returns the validation error message if the field has been touched or the form failed to submit.'),
        ]),
        li([
          code([.text('handle.dirty')]),
          .text(' — Checks whether this field differs from its original seeded baseline.'),
        ]),
        li([
          code([.text('handle.markReadOnly() / unmarkReadOnly()')]),
          .text(' — Freezes or unfreezes the field against any edits.'),
        ]),
      ]),

      // ---------------------------------------------------------------------
      // 2.3 Cross-Field Relations
      // ---------------------------------------------------------------------
      div(id: 'relations', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 02.3 · CROSS-FIELD RELATIONS')]),
      h2(classes: 'docs-h2 display', [.text('Cross-Field Relations')]),
      p([
        .text(
          "In complex forms, computing a derived value (like an auto-calculated total from a list of line items) easily spirals into an infinite listener loop. `keyed_form` solves this cleanly with `form.addRelation`:",
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/invoice/invoice_screen.dart',
        language: 'dart',
        rawSnippet: '''// Register a relation: whenever lineItems changes, recompute the total
late final VoidCallback _unsubscribeTotal;

@override
void initState() {
  super.initState();
  // Freeze the total field so the user can't type into it
  form.markReadOnly(InvoiceFields.total.key);

  _unsubscribeTotal = form.addRelation(
    InvoiceFields.lineItems,
    (items) => items.fold(0, (sum, item) => sum + item.quantity * item.unitPrice),
    (total) => form.field(InvoiceFields.total).set(total, force: true),
  );
}

@override
void dispose() {
  _unsubscribeTotal(); // Tear down the relation cleanly
  form.dispose();
  super.dispose();
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Declare an auto-derived relation with addRelation\n')]),
          .text('_unsubscribeTotal = form.'),
          span(classes: 'syntax-fn', [.text('addRelation')]),
          .text('(\n  InvoiceFields.lineItems,\n  (items) => items.fold('),
          span(classes: 'syntax-num', [.text('0')]),
          .text(
            ', (sum, item) => sum + item.quantity * item.unitPrice),\n  (total) => form.field(InvoiceFields.total).',
          ),
          span(classes: 'syntax-fn', [.text('set')]),
          .text('(total, force: '),
          span(classes: 'syntax-kw', [.text('true')]),
          .text('),\n);'),
        ]),
      ),

      // ---------------------------------------------------------------------
      // 2.4 Declarative & Async Validation
      // ---------------------------------------------------------------------
      div(id: 'validation', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 02.4 · VALIDATION')]),
      h2(classes: 'docs-h2 display', [.text('Declarative & Asynchronous Validation')]),
      p([
        .text(
          '`keyed_form` cleanly separates synchronous validation (defined in the Schema with `ks`) from asynchronous validation (a server round-trip to check an email/username) through `validateAsync`:',
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/login/login_screen.dart',
        language: 'dart',
        rawSnippet: '''// 1. Async validation over the network, with a timeout
KeyedFormField.text<LoginSchema>(
  field: LoginFields.email,
  builder: (context, f, controller) {
    void checkEmail() {
      f.onBlur();
      form.field(LoginFields.email).validateAsync(
        () => api.checkEmailTaken(f.value ?? ''),
        timeout: const Duration(seconds: 5),
      );
    }

    return TextField(
      controller: controller,
      onTapOutside: (_) => checkEmail(),
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: f.errorText,
        suffixIcon: f.isValidating
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
    );
  },
);

// 2. Map a 422 response from the API directly onto the matching FieldKey
form.setServerErrorPaths({
  'email': 'This email is already registered',
});''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Async validation with validateAsync\n')]),
          .text('form.field(LoginFields.email).'),
          span(classes: 'syntax-fn', [.text('validateAsync')]),
          .text('(\n  () => api.checkEmailTaken(f.value ?? '),
          span(classes: 'syntax-str', [.text("''")]),
          .text('),\n  timeout: '),
          span(classes: 'syntax-kw', [.text('const ')]),
          span(classes: 'syntax-type', [.text('Duration')]),
          .text('(seconds: '),
          span(classes: 'syntax-num', [.text('5')]),
          .text('),\n);\n\n'),
          span(classes: 'syntax-comment', [.text('// Map a 422 backend error straight onto the form\n')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('setServerErrorPaths')]),
          .text('({\n  '),
          span(classes: 'syntax-str', [.text("'email'")]),
          .text(': '),
          span(classes: 'syntax-str', [.text("'This email is already registered'")]),
          .text(',\n});'),
        ]),
      ),

      // ---------------------------------------------------------------------
      // 2.5 Reading Form State Reactively
      // ---------------------------------------------------------------------
      div(id: 'reactive-reads', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 02.5 · REACTIVE READS')]),
      h2(classes: 'docs-h2 display', [.text('Reading Form State Outside a Field')]),
      p([
        .text(
          "`KeyedFormField` covers the common case — one field, one widget. But sometimes you need to read a slice of form state somewhere that isn't itself an input: a computed total in an app bar, a whole section that only appears when a checkbox is on. For that, keyed_form installs a hidden reactive scope under `KeyedForm` that a few `BuildContext` extensions and widgets read from, so a widget depends on exactly the slice it needs instead of the whole form.",
        ),
      ]),
      ul(classes: 'docs-list', [
        li([
          code([.text('context.watchForm<Root>()')]),
          .text(' — the whole draft; rebuilds on any change to it. The blunt instrument — prefer a narrower read below when you can.'),
        ]),
        li([
          code([.text('context.watchField<Root, V>(ref)')]),
          .text(" — one field's current value; rebuilds only when it changes. Its error/dirty state live on the controller, not here — pair it with `selectForm` for those."),
        ]),
        li([
          code([.text('context.selectForm<Root, T>(selector, {equals})')]),
          .text(' — a derived slice; rebuilds only when `selector(form)` changes (`==` by default, or a custom `equals` for a collection). The selector must not write to the controller.'),
        ]),
        li([
          code([.text('KeyedFormSelector<Root, T>({selector, builder, child})')]),
          .text(
            ' — the widget form of `selectForm`, for scoping the rebuild to a subtree instead of lifting the read into an expensive parent `build()`. `child` is a subtree that doesn\'t depend on the slice — built once and handed to `builder` un-rebuilt.',
          ),
        ]),
        li([
          code([.text('KeyedFormBuilder<Root>({builder})')]),
          .text(
            ' — rebuilds on every controller change, no matter what. The whole-form escape hatch for something that genuinely needs everything (a debug state inspector) — reach for the scoped options above first.',
          ),
        ]),
      ]),
      p([
        .text(
          'All five require calling from inside `build()`, under a `KeyedForm<Root>` ancestor, and none may be called from inside another selector\'s callback (nesting throws in debug mode). A derived total shown outside any field looks like this:',
        ),
      ]),
      const DocsCodeBlock(
        title: 'lib/invoice/invoice_total_bar.dart',
        language: 'dart',
        rawSnippet: '''class InvoiceTotalBar extends StatelessWidget {
  const InvoiceTotalBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when the computed total actually changes, not on every
    // keystroke in an unrelated field.
    final total = context.selectForm<InvoiceSchema, num>(
      (form) => form.value.lineItems.fold(0, (sum, i) => sum + i.quantity * i.unitPrice),
    );

    return BottomAppBar(
      child: Text('Total: \$total'),
    );
  }
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Rebuilds only when the computed total changes\n')]),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('total = context.'),
          span(classes: 'syntax-fn', [.text('selectForm')]),
          .text('<'),
          span(classes: 'syntax-type', [.text('InvoiceSchema')]),
          .text(', '),
          span(classes: 'syntax-type', [.text('num')]),
          .text('>(\n  (form) => form.value.lineItems.fold('),
          span(classes: 'syntax-num', [.text('0')]),
          .text(', (sum, i) => sum + i.quantity * i.unitPrice),\n);'),
        ]),
      ),
    ]);
  }
}
