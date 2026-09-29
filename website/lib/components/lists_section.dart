import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';
import '../code/code_tabs.dart';
import '../example_sources.dart';
import 'demo/packing_demo.dart';

class ListsSection extends StatelessComponent {
  const ListsSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'lists', classes: 'wrap', [
      span(classes: 'section-kicker mono', [.text('// DYNAMIC LISTS')]),
      h2(classes: 'section-title display', [.text('Dynamic lists that never lose their place.')]),
      p(classes: 'section-lede', [
        .text(
          'Rows are addressed by a stable id, never by index. Type in row 2, then drag it to the top — '
          'the text, the error and the focus go with it.',
        ),
      ]),
      div(classes: 'split', [
        div(classes: 'split-code', [
          CodeTabs(
            id: 'lists-code',
            tabs: [
              for (final path in ExampleFiles.packing) CodeTab(path.split('/').last, ExampleSources.of(context, path)),
            ],
            caption: Component.fragment([
              .text("The example app's own files. "),
              a(
                href:
                    'https://github.com/iamv4g/keyed_form/tree/main/packages/keyed_form_flutter/example/lib/packing_list',
                target: Target.blank,
                [
                  strong([.text('Run the example')]),
                ],
              ),
              .text(' ↗'),
            ]),
          ),
        ]),
        div(classes: 'split-demo', [
          const PackingDemo(),
          p(classes: 'demo-credit mono', [
            .text('Drag & drop by '),
            a(href: 'https://iamv4g.github.io/dnd_kit/', target: Target.blank, [
              strong([.text('dnd_kit')]),
            ]),
            .text(' (Flutter · Jaspr) ↗'),
          ]),
        ]),
      ]),
      ul(classes: 'points', [
        li([
          span([
            strong([.text('Rows have ids, not indexes. ')]),
            .text('Every row carries a '),
            code([.text('clientId')]),
            .text('; field refs, errors and touched state are keyed by it, so a reorder moves them with the row.'),
          ]),
        ]),
        li([
          span([
            strong([.text('One call per edit. ')]),
            code([.text('list.move')]),
            .text(', '),
            code([.text('append')]),
            .text(', '),
            code([.text('removeById')]),
            .text(' — the list editor works the same whether a drag, a button or a server patch asked for it.'),
          ]),
        ]),
        li([
          span([
            strong([.text('Rules for the whole list. ')]),
            code([.text('.min(1)')]),
            .text(' and cross-row checks sit on the list itself, beside the per-row rules.'),
          ]),
        ]),
      ]),
      a(classes: 'section-link mono', href: '$siteBasePath/docs/long-lists', [
        .text('Lists, virtualization & scroll-to-error →'),
      ]),
    ]);
  }
}
