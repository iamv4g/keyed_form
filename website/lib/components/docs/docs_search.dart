import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

/// The header's Search button and its dialog. Opens on click or ⌘K / Ctrl+K,
/// filters [entries] as you type, ↑/↓ + Enter to jump. Everything runs in
/// the browser over the index the server built.
@client
class DocsSearch extends StatefulComponent {
  const DocsSearch({required this.entries, super.key});

  /// `title`, Markdown `section`, `docSection`, `docSectionTitle`, `url`, `text`.
  final List<Map<String, String>> entries;

  @override
  State<DocsSearch> createState() => _DocsSearchState();
}

class _DocsSearchState extends State<DocsSearch> {
  bool _open = false;
  String _query = '';
  int _selected = 0;
  StreamSubscription<web.KeyboardEvent>? _keys;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _keys = web.EventStreamProviders.keyDownEvent.forTarget(web.document).listen(_onKey);
    }
  }

  @override
  void dispose() {
    _keys?.cancel();
    super.dispose();
  }

  void _onKey(web.KeyboardEvent e) {
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() == 'k') {
      e.preventDefault();
      _open ? _close() : _show();
      return;
    }
    if (!_open) return;
    final count = _results.length;
    switch (e.key) {
      case 'Escape':
        _close();
      case 'ArrowDown' when count > 0:
        e.preventDefault();
        setState(() => _selected = (_selected + 1) % count);
      case 'ArrowUp' when count > 0:
        e.preventDefault();
        setState(() => _selected = (_selected - 1 + count) % count);
      case 'Enter' when count > 0:
        e.preventDefault();
        web.window.location.href = _results[_selected]['url']!;
    }
  }

  void _show() {
    setState(() {
      _open = true;
      _selected = 0;
    });
    Future(() => (web.document.querySelector('.search-input') as web.HTMLElement?)?.focus());
  }

  void _close() => setState(() => _open = false);

  List<Map<String, String>> get _results {
    final terms = _query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return const [];
    final scored = <(int, Map<String, String>)>[];
    for (final entry in component.entries) {
      final title = entry['title']!.toLowerCase();
      final section = entry['section']!.toLowerCase();
      final docSectionTitle = entry['docSectionTitle']!.toLowerCase();
      final text = entry['text']!.toLowerCase();
      var score = 0;
      for (final term in terms) {
        if (title.contains(term)) {
          score += 3;
        } else if (section.contains(term)) {
          score += 2;
        } else if (docSectionTitle.contains(term) || text.contains(term)) {
          score += 1;
        } else {
          score = 0;
          break;
        }
      }
      if (score > 0) scored.add((score, entry));
    }
    scored.sort((x, y) => y.$1.compareTo(x.$1));
    return [for (final (_, entry) in scored.take(8)) entry];
  }

  @override
  Component build(BuildContext context) {
    final results = _results;
    return Component.fragment([
      button(
        type: ButtonType.button,
        classes: 'search-button',
        attributes: {'aria-label': 'Search'},
        onClick: _show,
        [
          _searchIcon,
          span(classes: 'search-label', [.text('Search')]),
          _kbd('⌘K'),
        ],
      ),
      if (_open)
        div(
          classes: 'search-overlay',
          events: {
            'click': (e) {
              if (e.target == e.currentTarget) _close();
            },
          },
          [
            div(
              classes: 'search-dialog',
              attributes: {'role': 'dialog', 'aria-label': 'Search the docs'},
              [
                div(classes: 'search-field', [
                  _searchIcon,
                  input<String>(
                    type: InputType.search,
                    classes: 'search-input',
                    attributes: {'placeholder': 'Search the docs', 'autocomplete': 'off'},
                    value: _query,
                    onInput: (v) => setState(() {
                      _query = v;
                      _selected = 0;
                    }),
                  ),
                  _kbd('Esc'),
                ]),
                if (_query.trim().isNotEmpty && results.isEmpty)
                  p(classes: 'search-empty', [.text('No results for "${_query.trim()}".')]),
                if (results.isNotEmpty)
                  ul(classes: 'search-results', [
                    for (var i = 0; i < results.length; i++)
                      li([
                        a(
                          classes: i == _selected ? 'search-result selected' : 'search-result',
                          href: results[i]['url']!,
                          [
                            span(classes: 'search-result-title', [
                              .text('${results[i]['docSectionTitle']} › ${results[i]['title']}'),
                              if (results[i]['section']!.isNotEmpty) .text(' › ${results[i]['section']}'),
                            ]),
                            span(classes: 'search-result-text', [.text(results[i]['text']!)]),
                          ],
                        ),
                      ]),
                  ]),
              ],
            ),
          ],
        ),
    ]);
  }
}

// jaspr has no builder for <kbd>.
Component _kbd(String keys) => Component.element(tag: 'kbd', classes: 'search-kbd', children: [Component.text(keys)]);

final _searchIcon = svg(
  viewBox: '0 0 24 24',
  width: 16.px,
  height: 16.px,
  attributes: {'fill': 'currentColor', 'aria-hidden': 'true'},
  [
    path(
      d: 'M11 2C15.968 2 20 6.032 20 11C20 15.968 15.968 20 11 20C6.032 20 2 15.968 2 11C2 6.032 6.032 2 11 2ZM11 18C14.8675 18 18 14.8675 18 11C18 7.1325 14.8675 4 11 4C7.1325 4 4 7.1325 4 11C4 14.8675 7.1325 18 11 18ZM19.4853 18.0711L22.3137 20.8995L20.8995 22.3137L18.0711 19.4853L19.4853 18.0711Z',
      [],
    ),
  ],
);
