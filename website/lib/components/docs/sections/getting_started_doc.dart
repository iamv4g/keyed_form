import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_callout.dart';
import '../docs_code_block.dart';

class GettingStartedDoc extends StatelessComponent {
  const GettingStartedDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      // ---------------------------------------------------------------------
      // 1.1 Overview & Problem Statement
      // ---------------------------------------------------------------------
      div(id: 'overview', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono', [.text('// 01.1 · THE PARADIGM SHIFT')]),
      h2(classes: 'docs-h2 display', [.text('Overview & The Problem with Traditional Forms')]),
      p(classes: 'docs-lead', [
        .text(
          'Managing forms in Flutter has historically suffered from two opposing architectural flaws: either tightly coupling state to transient UI widgets, or relying on fragile, untyped strings.',
        ),
      ]),
      p([
        .text(
          'In traditional Flutter forms (`Form` + `TextFormField` + `TextEditingController`), state lives inside `StatefulWidget` instances. As soon as a field scrolls out of viewport in a `ListView.builder`, its `State` is disposed. When it scrolls back in, your draft input is wiped out or swapped with another cell.',
        ),
      ]),
      p([
        .text(
          'Conversely, string-keyed form architectures attempt decoupling by addressing controls via string paths like `form.control("stops.0.city")`. This introduces silent runtime crashes during refactoring, zero IDE autocomplete, and severe state crosstalk when array indices shift during reordering.',
        ),
      ]),

      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          thead([
            tr([
              th([.text('Capability / Invariant')]),
              th([.text('Vanilla Flutter Form')]),
              th([.text('String-Based Forms')]),
              th(classes: 'us', [.text('keyed_form')]),
            ]),
          ]),
          tbody([
            tr([
              td(classes: 'feat', [.text('Nested Immutable Updates')]),
              td([.text('Manual copyWith chains')]),
              td([.text('Manual copyWith chains')]),
              td(classes: 'yes', [.text('Embedded in generated FieldRef')]),
            ]),
            tr([
              td(classes: 'feat', [.text('Type Safety & Refactoring')]),
              td([.text('Manual glue code')]),
              td([.text('Fragile string keys ("user.age")')]),
              td(classes: 'yes', [.text('100% Compile-time Verified')]),
            ]),
            tr([
              td(classes: 'feat', [.text('Virtualization & Lazy Scroll')]),
              td([.text('State lost on widget dispose')]),
              td([.text('Requires manual form keeping')]),
              td(classes: 'yes', [.text('Immune to Widget Disposal')]),
            ]),
            tr([
              td(classes: 'feat', [.text('Reorder & Dynamic Lists')]),
              td([.text('Index crosstalk bugs')]),
              td([.text('Array shift validation errors')]),
              td(classes: 'yes', [.text('Stable RowId (UUID-backed)')]),
            ]),
            tr([
              td(classes: 'feat', [.text('Rebuild Granularity')]),
              td([.text('Whole form rebuilds')]),
              td([.text('Listener sprawl')]),
              td(classes: 'yes', [.text('Strict O(1) Per-Field Target')]),
            ]),
            tr([
              td(classes: 'feat', [.text('Testing Velocity')]),
              td([.text('Requires testWidgets() (~1.5s)')]),
              td([.text('Requires mock controls')]),
              td(classes: 'yes', [.text('Pure Dart in < 2ms')]),
            ]),
          ]),
        ]),
      ]),

      // ---------------------------------------------------------------------
      // 1.2 The Mental Model & Reassurance
      // ---------------------------------------------------------------------
      div(id: 'mental-model', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 01.2 · THE MENTAL MODEL')]),
      h2(classes: 'docs-h2 display', [.text('Thinking in Keyed Optics')]),

      p(classes: 'docs-lead', [
        .text(
          'Building forms robustly in Flutter requires a fundamental shift in how you think about input state: ',
        ),
        b([
          .text(
            "a form is not a widget tree — it's a pure, immutable data value.",
          ),
        ]),
      ]),

      h3(classes: 'docs-h3 display mt-24', [.text('4 Core Pillars of the keyed_form Architecture')]),
      ul(classes: 'docs-list', [
        li([
          b([.text('1. State Is a Pure Value (Immutable Root)')]),
          .text(
            ": The form's entire data lives in a single immutable data object (`Root`). State exists fully independent of the Flutter engine — you can construct a form, unit-test 100% of its logic in under 2ms, serialize it to JSON, or cache it, all without mounting a single widget.",
          ),
        ]),
        li([
          b([.text('2. FieldRef Is a Composable, Immutable Coordinate')]),
          .text(
            ': Instead of looking up a field by string or array index, every field is identified by a `FieldRef<Root, V>` — a statically-typed, compiler-checked coordinate that knows its exact value type (String, int, DateTime), gives full IDE autocomplete, and can never be misspelled. Because a `FieldRef` composes (`TourFields.stop(ref).nights` chains a list-row lookup with a property lookup), the nested `copyWith` chain needed to update that value is generated and embedded in the ref itself — you never hand-write it.',
          ),
        ]),
        li([
          b([.text('3. Keyed Identity (KeyedRow.clientId) Instead of Array Index [i]')]),
          .text(
            ": In a dynamic list, elements aren't identified by their array position `0, 1, 2` (which shifts on every insert or delete), but by a stable `clientId` tied to the record's lifecycle. As the user scrolls thousands of pixels or drags rows to reorder, each input stays locked to the correct record — crosstalk is structurally impossible.",
          ),
        ]),
        li([
          b([.text('4. Scoped O(1) Observation')]),
          .text(
            ': Each input widget observes exactly the one `FieldRef` it owns, through `KeyedFormField`. When the user types into a field, only that field rebuilds — never the rest of the form.',
          ),
        ]),
      ]),

      const DocsCallout(
        type: CalloutType.reassurance,
        title: "Don't Worry About Optics / Lenses! Learn the Standard Form Vocabulary Instead",
        content: Component.fragment([
          p([
            .text(
              'Hearing terms like "Functional Optics" or "Lenses" makes many developers worry they need to master category theory or functional programming. In reality: ',
            ),
            b([.text('you never need to understand the math to master keyed_form.')]),
          ]),
          p([
            .text(
              'The entire mathematical machinery of optics is sealed under the hood, acting as a silent guard that enforces type safety at compile time. What you actually write and use day to day is a ',
            ),
            b([.text('completely ordinary, familiar form vocabulary:')]),
          ]),
          ul(classes: 'docs-list', [
            li([
              code([.text('form.field(ref).value')]),
              .text(' — Read the field\'s current value with its exact type.'),
            ]),
            li([
              code([.text('form.field(ref).set(newValue)')]),
              .text(' — Write a new value, triggering a rebuild of only that widget.'),
            ]),
            li([
              code([.text('form.field(ref).update((current) => ...)')]),
              .text(' — Transform the value atomically through a function.'),
            ]),
            li([
              code([.text('form.field(ref).error')]),
              .text(' — Read the validation error, if the field has been touched or submit failed.'),
            ]),
            li([
              code([.text('form.handleSubmit(context, onValid)')]),
              .text(' — Submit safely, auto-scrolling and focusing the first invalid field on failure.'),
            ]),
            li([
              code([.text('form.field(listRef).list().append(...)')]),
              .text(' / '),
              code([.text('removeById(clientId)')]),
              .text(' — Add, remove, or move rows in a dynamic list by their stable clientId.'),
            ]),
          ]),
        ]),
      ),

      // ---------------------------------------------------------------------
      // 1.3 Quickstart
      // ---------------------------------------------------------------------
      div(id: 'quickstart', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 01.3 · QUICKSTART')]),
      h2(classes: 'docs-h2 display', [.text('Quickstart in 5 Minutes')]),
      p([
        .text(
          'Build and master your first form in 4 standard steps using the `keyed_form` toolkit:',
        ),
      ]),

      h3(classes: 'docs-h3 display', [.text('Step 1: Install the Packages')]),
      p([.text('Add the dependencies to your Flutter project:')]),
      const DocsCodeBlock(
        title: 'terminal',
        language: 'sh',
        rawSnippet:
            'flutter pub add keyed_form_flutter keyed_form_schema\nflutter pub add -d keyed_form_gen build_runner',
        code: Component.fragment([
          span(classes: 'syntax-prompt', [.text('\$ ')]),
          span(classes: 'syntax-cmd', [.text('flutter pub add ')]),
          span(classes: 'syntax-arg', [.text('keyed_form_flutter keyed_form_schema\n')]),
          span(classes: 'syntax-prompt', [.text('\$ ')]),
          span(classes: 'syntax-cmd', [.text('flutter pub add -d ')]),
          span(classes: 'syntax-arg', [.text('keyed_form_gen build_runner')]),
        ]),
      ),

      h3(classes: 'docs-h3 display', [.text('Step 2: Declare a Schema with @keyedSchema and ks.object')]),
      p([
        .text('Create a schema file defining the form\'s data structure and validation rules:'),
      ]),
      const DocsCodeBlock(
        title: 'lib/login/login_schema.dart',
        language: 'dart',
        rawSnippet: '''@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'login_schema.kfg.dart';

final _loginSchema = ks.object({
  'email': ks
      .string(error: .text('Email is required'))
      .email(error: .text('Invalid email address')),
  'password': ks
      .string(error: .text('Password is required'))
      .min(8, error: .text('Password must be at least 8 characters')),
  'remember': ks.boolean().defaultTo(false),
});''',
        code: Component.fragment([
          span(classes: 'syntax-ann', [.text('@keyedSchema\n')]),
          span(classes: 'syntax-kw', [.text('library;\n\n')]),
          span(classes: 'syntax-kw', [.text('import ')]),
          span(classes: 'syntax-str', [.text("'package:keyed_form_schema/keyed_form_schema.dart';\n\n")]),
          span(classes: 'syntax-kw', [.text('part ')]),
          span(classes: 'syntax-str', [.text("'login_schema.kfg.dart';\n\n")]),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('_loginSchema = '),
          span(classes: 'syntax-type', [.text('ks')]),
          .text('.'),
          span(classes: 'syntax-fn', [.text('object')]),
          .text('({\n  '),
          span(classes: 'syntax-str', [.text("'email'")]),
          .text(': '),
          span(classes: 'syntax-type', [.text('ks')]),
          .text('.'),
          span(classes: 'syntax-fn', [.text('string')]),
          .text('('),
          span(classes: 'syntax-arg', [.text('error: ')]),
          .text('.text('),
          span(classes: 'syntax-str', [.text("'Email is required'")]),
          .text(')).'),
          span(classes: 'syntax-fn', [.text('email')]),
          .text('('),
          span(classes: 'syntax-arg', [.text('error: ')]),
          .text('.text('),
          span(classes: 'syntax-str', [.text("'Invalid email address'")]),
          .text(')),\n  '),
          span(classes: 'syntax-str', [.text("'password'")]),
          .text(': '),
          span(classes: 'syntax-type', [.text('ks')]),
          .text('.'),
          span(classes: 'syntax-fn', [.text('string')]),
          .text('('),
          span(classes: 'syntax-arg', [.text('error: ')]),
          .text('.text('),
          span(classes: 'syntax-str', [.text("'Password is required'")]),
          .text(')).'),
          span(classes: 'syntax-fn', [.text('min')]),
          .text('('),
          span(classes: 'syntax-num', [.text('8')]),
          .text(', '),
          span(classes: 'syntax-arg', [.text('error: ')]),
          .text('.text('),
          span(classes: 'syntax-str', [.text("'Password must be at least 8 characters'")]),
          .text(')),\n  '),
          span(classes: 'syntax-str', [.text("'remember'")]),
          .text(': '),
          span(classes: 'syntax-type', [.text('ks')]),
          .text('.'),
          span(classes: 'syntax-fn', [.text('boolean')]),
          .text('().'),
          span(classes: 'syntax-fn', [.text('defaultTo')]),
          .text('('),
          span(classes: 'syntax-kw', [.text('false')]),
          .text('),\n});'),
        ]),
      ),

      h3(classes: 'docs-h3 display', [.text('Step 3: Run the Code Generator')]),
      p([
        .text(
          'Run the following command to generate the immutable `LoginSchema` model, the `LoginFields` field coordinates, and the `LoginSchema.validateData` validator:',
        ),
      ]),
      const DocsCodeBlock(
        title: 'terminal',
        language: 'sh',
        rawSnippet: 'dart run build_runner build -d',
        code: Component.fragment([
          span(classes: 'syntax-prompt', [.text('\$ ')]),
          span(classes: 'syntax-cmd', [.text('dart run build_runner build -d')]),
        ]),
      ),

      h3(classes: 'docs-h3 display', [.text('Step 4: Wire It Into the Flutter UI')]),
      p([
        .text(
          'Create a `KeyedFormController`, wrap the UI tree in `KeyedForm`, and bind inputs with `KeyedFormField.text`:',
        ),
      ]),
      const DocsCodeBlock(
        title: 'lib/login/login_screen.dart',
        language: 'dart',
        rawSnippet: '''class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = KeyedFormController<LoginSchema>(
    initialValue: LoginSchema.create(),
    mode: KeyedFormMode.onChange,
    resolver: LoginSchema.validateData,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedForm<LoginSchema>(
      controller: form,
      child: Column(
        children: [
          KeyedFormField.text<LoginSchema>(
            field: LoginFields.email,
            builder: (context, f, controller) => TextField(
              controller: controller,
              onTapOutside: (_) => f.onBlur(),
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: f.errorText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          KeyedFormField.text<LoginSchema>(
            field: LoginFields.password,
            builder: (context, f, controller) => TextField(
              controller: controller,
              obscureText: true,
              onTapOutside: (_) => f.onBlur(),
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: f.errorText,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => form.handleSubmit(context, (data) async {
              print('Logged in successfully with email: \${data.email}');
            }),
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Initialize the controller with the generated Schema\n')]),
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
          span(classes: 'syntax-comment', [.text('// Wrap the UI in KeyedForm and use KeyedFormField.text\n')]),
          span(classes: 'syntax-type', [.text('KeyedForm<LoginSchema>')]),
          .text('(\n  controller: form,\n  child: Column(children: [\n    '),
          span(classes: 'syntax-type', [.text('KeyedFormField')]),
          .text('.text<LoginSchema>(\n      field: '),
          span(classes: 'syntax-type', [.text('LoginFields')]),
          .text(
            '.email,\n      builder: (context, f, controller) => TextField(\n        controller: controller,\n        onTapOutside: (_) => f.onBlur(),\n        decoration: InputDecoration(labelText: ',
          ),
          span(classes: 'syntax-str', [.text("'Email'")]),
          .text(
            ', errorText: f.errorText),\n      ),\n    ),\n    ElevatedButton(\n      onPressed: () => form.handleSubmit(context, (data) ',
          ),
          span(classes: 'syntax-kw', [.text('async ')]),
          .text('{\n        print(data.email);\n      }),\n      child: const Text('),
          span(classes: 'syntax-str', [.text("'Log In'")]),
          .text('),\n    ),\n  ]),\n);'),
        ]),
      ),
    ]);
  }
}
