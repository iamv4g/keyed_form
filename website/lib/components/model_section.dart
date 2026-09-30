import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import '../code/code_tabs.dart';
import '../example_sources.dart';
import 'demo/model_login_demo.dart';

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
            tabs: [
              for (final path in ExampleFiles.login) CodeTab(path.split('/').last, ExampleSources.of(context, path)),
            ],
            caption: Component.fragment([
              .text("The example app's own files. "),
              a(
                href: 'https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/login',
                target: Target.blank,
                [
                  strong([.text('Run the example')]),
                ],
              ),
              .text(' ↗'),
            ]),
          ),
        ]),
        div(classes: 'split-demo', [const ModelLoginDemo()]),
      ]),
      ul(classes: 'points', [
        li([
          span([
            strong([.text('One draft, one controller. ')]),
            .text('The whole form is one immutable value; fields are addresses into it, not objects to wire up.'),
          ]),
        ]),
        li([
          span([
            strong([.text('Refs, not strings. ')]),
            code([.text('LoginFields.email')]),
            .text(' is a typed field ref — rename a field and the compiler finds every use.'),
          ]),
        ]),
        li([
          span([
            strong([.text('Headless by design. ')]),
            code([.text('KeyedFormField')]),
            .text(
              ' hands you the value, the error and a text controller; render with Material, Cupertino or your own design system.',
            ),
          ]),
        ]),
      ]),
      a(classes: 'section-link mono', href: '$siteBasePath/docs/guides/quickstart', [.text('Quickstart in 5 minutes →')]),
    ]);
  }
}
