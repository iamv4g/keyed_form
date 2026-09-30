import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

/// "On this page": the page's h2/h3 list, marking the section being read.
@client
class DocsToc extends StatefulComponent {
  const DocsToc({required this.entries, super.key});

  /// `text`, `id`, `href` and `depth` (`0` for h2, `1` for h3) per heading.
  final List<Map<String, String>> entries;

  @override
  State<DocsToc> createState() => _DocsTocState();
}

class _DocsTocState extends State<DocsToc> {
  String? _active;
  StreamSubscription<web.Event>? _scroll;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _scroll = web.EventStreamProviders.scrollEvent.forTarget(web.window).listen((_) => _update());
      Future(_update);
    }
  }

  @override
  void dispose() {
    _scroll?.cancel();
    super.dispose();
  }

  // The last heading that has scrolled up to the header's bottom edge; the
  // last one outright once the page bottoms out.
  void _update() {
    final entries = component.entries;
    if (entries.isEmpty) return;
    String? active = entries.first['id'];
    final atBottom = web.window.innerHeight + web.window.scrollY >= web.document.documentElement!.scrollHeight - 2;
    if (atBottom) {
      active = entries.last['id'];
    } else {
      for (final entry in entries) {
        final el = web.document.getElementById(entry['id']!);
        if (el != null && el.getBoundingClientRect().top <= 120) active = entry['id'];
      }
    }
    if (active != _active) setState(() => _active = active);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'docs-toc-inner', [
      div(classes: 'docs-toc-header', [.text('On this page')]),
      ul(classes: 'md-toc', [
        for (final entry in component.entries)
          li([
            a(
              classes: [
                'md-toc-link',
                if (entry['depth'] == '1') 'nested',
                if (entry['id'] == _active) 'active',
              ].join(' '),
              href: entry['href']!,
              [.text(entry['text']!)],
            ),
          ]),
      ]),
    ]);
  }
}
