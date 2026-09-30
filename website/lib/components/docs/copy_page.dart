import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_lucide/jaspr_lucide.dart' as lucide;
import 'package:universal_web/web.dart' as web;

import '../icons.dart';

/// "Copy page" next to a docs page's title: copies the page's Markdown, and
/// its menu links to the raw Markdown and to the source on GitHub.
@client
class CopyPageButton extends StatefulComponent {
  const CopyPageButton({required this.markdown, required this.markdownUrl, required this.editUrl, super.key});

  final String markdown;
  final String markdownUrl;
  final String editUrl;

  @override
  State<CopyPageButton> createState() => _CopyPageButtonState();
}

class _CopyPageButtonState extends State<CopyPageButton> {
  bool _copied = false;
  bool _open = false;
  Timer? _timer;
  StreamSubscription<web.MouseEvent>? _clicks;
  StreamSubscription<web.KeyboardEvent>? _keys;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _clicks = web.EventStreamProviders.clickEvent.forTarget(web.document).listen((e) {
        // Clicks land on elements, never on text nodes.
        final target = e.target as web.Element?;
        if (_open && target?.closest('.copy-page') == null) {
          setState(() => _open = false);
        }
      });
      _keys = web.EventStreamProviders.keyDownEvent.forTarget(web.document).listen((e) {
        if (_open && e.key == 'Escape') setState(() => _open = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clicks?.cancel();
    _keys?.cancel();
    super.dispose();
  }

  void _copy() {
    if (!kIsWeb) return;
    web.window.navigator.clipboard.writeText(component.markdown);
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'copy-page', [
      div(
        classes: 'copy-page-group',
        attributes: {'role': 'group'},
        [
          button(
            type: ButtonType.button,
            classes: 'copy-page-button',
            attributes: {'aria-label': 'Copy page as Markdown'},
            onClick: _copy,
            [
              if (_copied) lucide.Check(width: 16.px, height: 16.px) else lucide.Copy(width: 16.px, height: 16.px),
              span(classes: 'copy-page-label', [.text(_copied ? 'Copied' : 'Copy page')]),
            ],
          ),
          button(
            type: ButtonType.button,
            classes: 'copy-page-button copy-page-trigger',
            attributes: {'aria-label': 'More page actions', 'aria-haspopup': 'menu', 'aria-expanded': '$_open'},
            onClick: () => setState(() => _open = !_open),
            [lucide.ChevronDown(width: 16.px, height: 16.px)],
          ),
        ],
      ),
      if (_open)
        div(
          classes: 'copy-page-menu',
          attributes: {'role': 'menu'},
          [
            _item(lucide.FileText(width: 16.px, height: 16.px), 'View as Markdown', component.markdownUrl),
            _item(SiteIcons.github(size: 16), 'Edit on GitHub', component.editUrl),
          ],
        ),
    ]);
  }

  Component _item(Component icon, String label, String href) {
    return a(
      classes: 'copy-page-item',
      href: href,
      target: Target.blank,
      attributes: {'role': 'menuitem', 'rel': 'noopener'},
      [
        icon,
        span([.text(label)]),
      ],
    );
  }
}
