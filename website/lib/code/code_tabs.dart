import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/copy_button.dart';
import 'highlight.dart';

class CodeTab {
  const CodeTab(this.fileName, this.code);

  final String fileName;
  final String code;
}

/// File tabs over highlighted Dart, switched by pure CSS: one radio input
/// per tab (a native radio group, so arrow keys move between tabs) and
/// `:checked ~` rules in [codeTabsStyles] reveal the matching panel. No
/// hydration, so the highlighter stays server-side.
///
/// [id] must be unique on the page — it namespaces the radio group.
/// Supports up to [maxTabs] tabs.
class CodeTabs extends StatelessComponent {
  const CodeTabs({required this.id, required this.tabs, this.caption, super.key});

  static const maxTabs = 4;

  final String id;
  final List<CodeTab> tabs;
  final Component? caption;

  @override
  Component build(BuildContext context) {
    assert(tabs.length <= maxTabs, 'codeStyles only has rules for $maxTabs tabs');
    return div(classes: 'code-tabs-box', [
      for (var i = 0; i < tabs.length; i++)
        input(
          id: '$id-$i',
          type: InputType.radio,
          name: id,
          classes: 'code-tab-input',
          checked: i == 0,
        ),
      div(classes: 'code-tabs-bar mono', [
        for (var i = 0; i < tabs.length; i++)
          label(htmlFor: '$id-$i', classes: 'code-tab-label', [.text(tabs[i].fileName)]),
      ]),
      div(classes: 'code-tab-panels', [
        for (final tab in tabs)
          div(classes: 'code-tab-panel', [
            CopyButton(text: tab.code),
            pre(classes: 'code-tab-pre mono', [code(highlightDart(tab.code))]),
          ]),
      ]),
      if (caption != null) div(classes: 'code-tabs-caption', [caption!]),
    ]);
  }
}
