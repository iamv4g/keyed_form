import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../code/code_tabs.dart';
import '../code/highlight.dart';
import '../components/demo/packing_demo.dart';
import '../example_sources.dart';

/// Fenced code blocks, highlighted with the site's own tk-* classes.
class KfCodeBlock extends CustomComponent {
  const KfCodeBlock() : super.base();

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node case ElementNode(tag: 'pre', children: [ElementNode(tag: 'code', :final children, :final attributes)])) {
      final source = (children ?? const <Node>[]).map((c) => c.innerText).join().trimRight();
      final language = attributes['class']?.replaceFirst('language-', '');
      return pre(classes: 'md-code mono', [
        code(language == 'dart' ? highlightDart(source) : [.text(source)]),
      ]);
    }
    return null;
  }
}

/// `<ExampleCode id="…" files="a.dart b.dart" />`: tabs over files of the
/// Flutter example, read at build time.
class ExampleCode extends CustomComponentBase {
  const ExampleCode();

  @override
  Pattern get pattern => 'ExampleCode';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    final files = (attributes['files'] ?? '').split(RegExp(r'\s+')).where((f) => f.isNotEmpty);
    return Builder(
      builder: (context) => CodeTabs(
        id: attributes['id'] ?? 'example-code',
        tabs: [for (final path in files) CodeTab(path.split('/').last, ExampleSources.of(context, path))],
      ),
    );
  }
}

/// `<PackingDemo />`: the landing page's drag-and-drop list demo.
class PackingDemoTag extends CustomComponentBase {
  const PackingDemoTag();

  @override
  Pattern get pattern => 'PackingDemo';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) => const PackingDemo();
}

/// `<Note>…</Note>`: the one callout style docs use.
class Note extends CustomComponentBase {
  const Note();

  @override
  Pattern get pattern => 'Note';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) => aside(classes: 'md-note', [?child]);
}
