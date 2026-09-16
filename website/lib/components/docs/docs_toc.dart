import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../base_path.dart';
import 'docs_nav_data.dart';

/// "ON THIS PAGE" — unlike [DocsSidebar] (the full site map), this only shows
/// the headings inside whichever chapter is currently scrolled into view, so
/// the two navs don't just duplicate each other on this single long page.
@client
class DocsToc extends StatefulComponent {
  const DocsToc({super.key});

  @override
  State<DocsToc> createState() => _DocsTocState();
}

class _DocsTocState extends State<DocsToc> {
  int _activeGroupIndex = 0;
  String? _activeHref;
  JSFunction? _scrollListener;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _scrollListener = _onScroll.toJS;
      web.window.addEventListener('scroll', _scrollListener);
      _onScroll();
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _scrollListener != null) {
      web.window.removeEventListener('scroll', _scrollListener);
    }
    super.dispose();
  }

  // The last heading whose top has scrolled above the sticky header is the
  // one currently being read.
  void _onScroll() {
    const headerOffset = 120.0;
    var bestGroup = 0;
    String? bestHref;

    for (var g = 0; g < docsNavGroups.length; g++) {
      for (final item in docsNavGroups[g].items) {
        final anchor = web.document.getElementById(item.href.substring(1));
        if (anchor == null) continue;
        if (anchor.getBoundingClientRect().top <= headerOffset) {
          bestGroup = g;
          bestHref = item.href;
        }
      }
    }

    if (bestGroup != _activeGroupIndex || bestHref != _activeHref) {
      setState(() {
        _activeGroupIndex = bestGroup;
        _activeHref = bestHref;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    final group = docsNavGroups[_activeGroupIndex];

    return aside(classes: 'docs-toc', [
      div(classes: 'docs-toc-header mono', [.text('ON THIS PAGE')]),
      div(classes: 'docs-toc-group-title mono', [.text(group.kicker)]),
      ul(classes: 'docs-toc-list', [
        for (final item in group.items)
          li([
            a(
              href: '$siteBasePath/docs${item.href}',
              classes: item.href == _activeHref ? 'active' : '',
              [.text(item.title)],
            ),
          ]),
      ]),
    ]);
  }
}
