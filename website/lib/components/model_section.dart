import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import '../code/code_tabs.dart';
import '../code/snippets/login_snippets.dart';
import 'demo/model_login_demo.dart';

/// "The Model": the login example's three files on one side, the same
/// schema and controller running on the other.
class ModelSection extends StatelessComponent {
  const ModelSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'model', classes: 'wrap', [
      span(classes: 'section-kicker mono', [.text('// THE MODEL')]),
      h2(classes: 'section-title display', [.text('Declare the shape once. Bind each field by name.')]),
      p(classes: 'section-lede', [
        .text(
          'One schema file; the generator does the rest; your widgets stay plain Flutter. '
          'The demo runs this exact schema and controller — submit it empty.',
        ),
      ]),
      div(classes: 'split', [
        div(classes: 'split-code', [
          CodeTabs(
            id: 'model-code',
            tabs: const [
              CodeTab('login_schema.dart', LoginSnippets.schema),
              CodeTab('login_form.dart', LoginSnippets.form),
              CodeTab('login_text_field.dart', LoginSnippets.textField),
            ],
            caption: Component.fragment([
              .text('Trimmed for the page. '),
              a(
                href: 'https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/login',
                target: Target.blank,
                [
                  strong([.text('Full example')]),
                ],
              ),
              .text(' — async email check, remember-me and submit flow ↗'),
            ]),
          ),
        ]),
        div(classes: 'split-demo', [const ModelLoginDemo()]),
      ]),
      ul(classes: 'points', [
        li([
          strong([.text('One draft, one controller. ')]),
          .text('The whole form is one immutable value; fields are addresses into it, not objects to wire up.'),
        ]),
        li([
          strong([.text('Refs, not strings. ')]),
          code([.text('LoginFields.email')]),
          .text(' is a typed field ref — rename a field and the compiler finds every use.'),
        ]),
        li([
          strong([.text('Headless by design. ')]),
          code([.text('KeyedFormField')]),
          .text(
            ' hands you the value, the error and a text controller; render with Material, Cupertino or your own design system.',
          ),
        ]),
      ]),
      a(classes: 'section-link mono', href: '$siteBasePath/docs#quickstart', [.text('Quickstart in 5 minutes →')]),
    ]);
  }
}
