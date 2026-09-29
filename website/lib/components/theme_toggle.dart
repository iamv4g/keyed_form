import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import 'icons.dart';

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

  // Both icons are always rendered; CSS shows the one matching the
  // current theme (see `.theme-icon-*` in sharedStyles). The pre-rendered
  // HTML can't know the visitor's theme, so a state-driven icon would
  // flash the wrong one until hydration.
  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      classes: 'theme-toggle',
      attributes: {
        'aria-label': _isDark ? 'Switch to light theme' : 'Switch to dark theme',
        'title': 'Toggle theme',
      },
      onClick: _toggle,
      [
        SiteIcons.sun(classes: 'theme-icon-sun'),
        SiteIcons.moon(classes: 'theme-icon-moon'),
      ],
    );
  }
}
