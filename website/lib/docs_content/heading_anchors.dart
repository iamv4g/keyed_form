import 'package:jaspr/dom.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../base_path.dart';

/// Puts a small `#` link beside each h2 and h3. The href carries the base
/// path: a bare `#id` would resolve against `<base>`.
class KfHeadingAnchors implements PageExtension {
  const KfHeadingAnchors();

  static final _heading = RegExp(r'^h[23]$');

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    return [for (final node in nodes) _process(node, page.url)];
  }

  Node _process(Node node, String url) {
    if (node is! ElementNode) return node;
    final id = node.attributes['id'];
    if (!_heading.hasMatch(node.tag) || id == null) {
      return ElementNode(node.tag, node.attributes, node.children?.map((c) => _process(c, url)).toList());
    }
    return ElementNode(
      node.tag,
      {...node.attributes, 'class': 'md-heading'},
      [
        ElementNode('span', {}, node.children),
        ComponentNode(
          a(
            classes: 'md-anchor',
            href: '$siteBasePath$url#$id',
            attributes: {'aria-label': 'Link to this section'},
            [.text('#')],
          ),
        ),
      ],
    );
  }
}
