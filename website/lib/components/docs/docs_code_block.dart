import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../copy_button.dart';

class DocsCodeBlock extends StatelessComponent {
  const DocsCodeBlock({
    required this.code,
    required this.rawSnippet,
    this.title = 'snippet.dart',
    this.language = 'dart',
    super.key,
  });

  final Component code;
  final String rawSnippet;
  final String title;
  final String language;

  @override
  Component build(BuildContext context) {
    return div(classes: 'docs-code-box', [
      div(classes: 'docs-code-header', [
        div(classes: 'docs-code-title mono', [
          span(classes: 'code-dot', []),
          .text(title),
        ]),
        div(classes: 'docs-code-actions', [
          span(classes: 'code-lang-tag mono', [.text(language.toUpperCase())]),
          CopyButton(text: rawSnippet, label: 'COPY'),
        ]),
      ]),
      pre(classes: 'docs-code-content mono', [
        code,
      ]),
    ]);
  }
}
