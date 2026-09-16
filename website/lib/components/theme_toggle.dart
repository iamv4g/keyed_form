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
      String? savedTheme;
      try {
        savedTheme = web.window.localStorage.getItem('theme');
      } catch (_) {}

      if (savedTheme != null && savedTheme.isNotEmpty) {
        _isDark = savedTheme == 'dark';
      } else {
        final current = web.document.documentElement?.getAttribute('data-theme');
        if (current != null && current.isNotEmpty) {
          _isDark = current == 'dark';
        } else {
          final isDarkScheme = web.window.matchMedia('(prefers-color-scheme: dark)').matches;
          final isLightScheme = web.window.matchMedia('(prefers-color-scheme: light)').matches;
          if (isLightScheme && !isDarkScheme) {
            _isDark = false;
          } else {
            _isDark = true;
          }
        }
      }
    }
  }

  void _toggle() {
    if (kIsWeb) {
      final next = _isDark ? 'light' : 'dark';
      web.document.documentElement?.setAttribute('data-theme', next);
      try {
        web.window.localStorage.setItem('theme', next);
      } catch (_) {}
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
