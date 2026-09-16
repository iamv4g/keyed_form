import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

enum CalloutType {
  reassurance,
  tip,
  warning,
  note,
}

class DocsCallout extends StatelessComponent {
  const DocsCallout({
    required this.title,
    required this.content,
    this.type = CalloutType.tip,
    super.key,
  });

  final String title;
  final Component content;
  final CalloutType type;

  @override
  Component build(BuildContext context) {
    final typeClass = switch (type) {
      CalloutType.reassurance => 'callout-reassurance',
      CalloutType.tip => 'callout-tip',
      CalloutType.warning => 'callout-warning',
      CalloutType.note => 'callout-note',
    };

    final kicker = switch (type) {
      CalloutType.reassurance => '// REASSURANCE · FORM VOCABULARY',
      CalloutType.tip => '// PRO-TIP',
      CalloutType.warning => '// CRITICAL INVARIANT',
      CalloutType.note => '// NOTE',
    };

    return div(classes: 'docs-callout $typeClass', [
      div(classes: 'callout-header', [
        span(classes: 'callout-kicker mono', [.text(kicker)]),
        h4(classes: 'callout-title display', [.text(title)]),
      ]),
      div(classes: 'callout-body', [content]),
    ]);
  }
}

