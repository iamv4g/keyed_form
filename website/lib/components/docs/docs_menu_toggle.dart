import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

/// Class toggled on `<html>` that [docsStyles]/[responsiveStyles] key the
/// drawer's visibility off, and the event [closeDocsMenu] fires so this
/// button's icon can resync when the drawer closes itself (backdrop or nav
/// link click, over in DocsSidebar) — the two are separate hydration
/// islands with no shared Dart state, so the DOM is the shared state.
const docsMenuOpenClass = 'docs-menu-open';
const docsMenuCloseEvent = 'docsmenu:close';

void closeDocsMenu() {
  if (!kIsWeb) return;
  web.document.documentElement?.classList.remove(docsMenuOpenClass);
  _markDialog(false);
  web.document.dispatchEvent(web.Event(docsMenuCloseEvent));
}

// While open, the sidebar panel is a modal dialog; on wide screens it is a
// plain column again.
void _markDialog(bool open) {
  final panel = web.document.querySelector('.md-sidebar-panel');
  if (panel == null) return;
  if (open) {
    panel
      ..setAttribute('role', 'dialog')
      ..setAttribute('aria-modal', 'true')
      ..setAttribute('aria-label', 'Sidebar');
  } else {
    panel
      ..removeAttribute('role')
      ..removeAttribute('aria-modal')
      ..removeAttribute('aria-label');
  }
}

/// The sidebar toggle in the docs header's tab row, shown on narrow screens.
@client
class DocsMenuToggle extends StatefulComponent {
  const DocsMenuToggle({super.key});

  @override
  State<DocsMenuToggle> createState() => _DocsMenuToggleState();
}

class _DocsMenuToggleState extends State<DocsMenuToggle> {
  bool _open = false;
  JSFunction? _closeListener;
  StreamSubscription<web.KeyboardEvent>? _keys;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _closeListener = (() => setState(() => _open = false)).toJS;
      web.document.addEventListener(docsMenuCloseEvent, _closeListener);
      _keys = web.EventStreamProviders.keyDownEvent.forTarget(web.document).listen((e) {
        if (_open && e.key == 'Escape') closeDocsMenu();
      });
    }
  }

  void _toggle() {
    if (!kIsWeb) return;
    final next = !_open;
    web.document.documentElement?.classList.toggle(docsMenuOpenClass, next);
    _markDialog(next);
    setState(() => _open = next);
  }

  @override
  void dispose() {
    _keys?.cancel();
    if (kIsWeb && _closeListener != null) {
      web.document.removeEventListener(docsMenuCloseEvent, _closeListener);
    }
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      classes: 'sidebar-trigger',
      attributes: {'aria-label': _open ? 'Close sidebar' : 'Open sidebar'},
      onClick: _toggle,
      [
        svg(
          viewBox: '0 0 24 24',
          width: 16.px,
          height: 16.px,
          attributes: {
            'fill': 'none',
            'stroke': 'currentColor',
            'stroke-width': '2',
            'stroke-linecap': 'round',
            'stroke-linejoin': 'round',
            'aria-hidden': 'true',
          },
          [
            rect(x: '3', y: '3', width: '18', height: '18', attributes: {'rx': '2'}, []),
            path(d: 'M9 3v18', []),
          ],
        ),
      ],
    );
  }
}
