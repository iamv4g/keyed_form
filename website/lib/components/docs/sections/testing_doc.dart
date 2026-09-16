import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_callout.dart';
import '../docs_code_block.dart';

class TestingDoc extends StatelessComponent {
  const TestingDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      div(id: 'testing-without-widgets', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 05 · TESTING VELOCITY')]),
      h2(classes: 'docs-h2 display', [.text('Testing Without Widgets: Pure Dart in < 2ms')]),

      const DocsCallout(
        type: CalloutType.tip,
        title: 'Speed Up CI/CD: Test 100% of Your Form Logic Without WidgetTester',
        content: Component.fragment([
          p([
            .text(
              "In large Flutter projects, `testWidgets()` eats up to 80% of CI pipeline time because it has to spin up a simulated Flutter Engine for every test. ",
            ),
            b([
              .text('With keyed_form, you can test an entire form with a plain `dart test` that runs in 1.8 milliseconds!'),
            ]),
          ]),
        ]),
      ),

      p([
        .text(
          "Because `KeyedFormController` is fully independent of the widget tree, you can test every scenario — valid input, a failed submit, cross-field relations, dirty tracking, diffing — in an ordinary pure unit test:",
        ),
      ]),

      const DocsCodeBlock(
        title: 'test/login_form_test.dart',
        language: 'dart',
        rawSnippet: '''import 'package:test/test.dart';
import 'package:keyed_form/keyed_form.dart';
import 'package:my_app/schemas/login_schema.dart';

void main() {
  test('Login form validates, tracks dirty state, and submits in < 2ms', () async {
    final form = KeyedFormController<LoginSchema>(
      initialValue: LoginSchema.create(email: 'user@domain.com', password: 'password123'),
      mode: KeyedFormMode.onChange,
      resolver: LoginSchema.validateData,
    );

    // 1. The form starts out completely clean
    expect(form.isDirty, isFalse);

    // 2. Simulate the user typing an invalid email
    form.field(LoginFields.email).set('invalid-email');
    expect(form.isDirty, isTrue);
    expect(form.differs(LoginFields.email), isTrue);
    expect(form.differs(LoginFields.password), isFalse);

    // 3. Try submitting while the data is invalid:
    // onInvalid receives the FieldKeys of every invalid field
    var submitted = false;
    final success = await form.submit(
      (draft) async => submitted = true,
      onInvalid: (errorKeys) {
        expect(errorKeys, contains(LoginFields.email.key));
      },
    );

    expect(success, isFalse);
    expect(submitted, isFalse);
    expect(form.visibleErrorFor(LoginFields.email), isNotNull);

    // 4. Fix the email and submit successfully
    form.field(LoginFields.email).set('valid@domain.com');
    final retrySuccess = await form.submit((draft) async {
      submitted = true;
      expect(draft.email, equals('valid@domain.com'));
    });

    expect(retrySuccess, isTrue);
    expect(submitted, isTrue);
    expect(form.visibleErrorFor(LoginFields.email), isNull);
  });
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// Pure Dart test — runs in 1.8ms, no testWidgets needed!\n')]),
          span(classes: 'syntax-fn', [.text('test')]),
          .text('('),
          span(classes: 'syntax-str', [.text("'Login form pure unit test'")]),
          .text(', () '),
          span(classes: 'syntax-kw', [.text('async ')]),
          .text('{\n  '),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('form = '),
          span(classes: 'syntax-type', [.text('KeyedFormController')]),
          .text('<'),
          span(classes: 'syntax-type', [.text('LoginSchema')]),
          .text('>(\n    initialValue: '),
          span(classes: 'syntax-type', [.text('LoginSchema')]),
          .text('.create(),\n    resolver: '),
          span(classes: 'syntax-type', [.text('LoginSchema')]),
          .text('.validateData,\n  );\n\n  form.'),
          span(classes: 'syntax-fn', [.text('field')]),
          .text('('),
          span(classes: 'syntax-type', [.text('LoginFields')]),
          .text('.email).'),
          span(classes: 'syntax-fn', [.text('set')]),
          .text('('),
          span(classes: 'syntax-str', [.text("'bad-email'")]),
          .text(');\n  '),
          span(classes: 'syntax-fn', [.text('expect')]),
          .text('(form.isDirty, isTrue);\n  '),
          span(classes: 'syntax-fn', [.text('expect')]),
          .text('(form.differs('),
          span(classes: 'syntax-type', [.text('LoginFields')]),
          .text('.email), isTrue);\n\n  '),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('success = '),
          span(classes: 'syntax-kw', [.text('await ')]),
          .text('form.'),
          span(classes: 'syntax-fn', [.text('submit')]),
          .text('((draft) '),
          span(classes: 'syntax-kw', [.text('async ')]),
          .text('=> save(draft));\n  '),
          span(classes: 'syntax-fn', [.text('expect')]),
          .text('(success, isFalse);\n});'),
        ]),
      ),
    ]);
  }
}
