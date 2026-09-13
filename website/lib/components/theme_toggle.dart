import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      final current = web.document.documentElement?.getAttribute('data-theme');
      if (current != null) {
        _isDark = current == 'dark';
      }
    }
  }

  void _toggle() {
    if (kIsWeb) {
      final next = _isDark ? 'light' : 'dark';
      web.document.documentElement?.setAttribute('data-theme', next);
      setState(() {
        _isDark = !_isDark;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'theme-toggle mono',
      onClick: _toggle,
      [
        span(id: 'theme-label', [
          .text(_isDark ? '☼ LIGHT' : '☽ DARK'),
        ]),
      ],
    );
  }
}
