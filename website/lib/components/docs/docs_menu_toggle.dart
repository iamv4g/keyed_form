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
  web.document.dispatchEvent(web.Event(docsMenuCloseEvent));
}

/// The "☰" button embedded in the shared Navbar, shown only on /docs at
/// mobile widths (see [Navbar.showDocsMenuToggle]).
@client
class DocsMenuToggle extends StatefulComponent {
  const DocsMenuToggle({super.key});

  @override
  State<DocsMenuToggle> createState() => _DocsMenuToggleState();
}

class _DocsMenuToggleState extends State<DocsMenuToggle> {
  bool _open = false;
  JSFunction? _closeListener;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _closeListener = (() => setState(() => _open = false)).toJS;
      web.document.addEventListener(docsMenuCloseEvent, _closeListener);
    }
  }

  void _toggle() {
    if (!kIsWeb) return;
    final next = !_open;
    web.document.documentElement?.classList.toggle(docsMenuOpenClass, next);
    setState(() => _open = next);
  }

  @override
  void dispose() {
    if (kIsWeb && _closeListener != null) {
      web.document.removeEventListener(docsMenuCloseEvent, _closeListener);
    }
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      classes: 'navbar-docs-toggle mono',
      attributes: {'aria-label': _open ? 'Close chapters menu' : 'Open chapters menu'},
      onClick: _toggle,
      [.text('☰')],
    );
  }
}
