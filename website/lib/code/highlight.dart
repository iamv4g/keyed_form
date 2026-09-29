import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart' as shl;

shl.Highlighter? _dart;

/// Loads the Dart grammar. Must complete before the first [highlightDart]
/// call — `main.server.dart` awaits it before `runApp`, tests in
/// `setUpAll`. Server-only: nothing in a `@client` component may import
/// this file, so the grammar never ships in the client bundle.
Future<void> initHighlighter() async {
  if (_dart != null) return;
  await shl.Highlighter.initialize(['dart']);
  // The theme's colors are ignored — spans are colored by CSS classes
  // derived from their TextMate scopes (see [tokenClassFor]), so the code
  // follows the site's light/dark tokens.
  _dart = shl.Highlighter(language: 'dart', theme: await shl.HighlighterTheme.loadDarkTheme());
}

/// [code] as highlighted `span`s, one per token, classed `tk-*`.
List<Component> highlightDart(String code) {
  final highlighter = _dart;
  if (highlighter == null) {
    throw StateError('highlightDart() called before initHighlighter() completed');
  }
  final out = <Component>[];
  void walk(shl.TextSpan node) {
    final text = node.text;
    if (text != null && text.isNotEmpty) {
      final cls = tokenClassFor(node.scopes);
      out.add(cls == null ? Component.text(text) : span(classes: cls, [Component.text(text)]));
    }
    node.children.forEach(walk);
  }

  walk(highlighter.highlight(code));
  return out;
}

/// The `tk-*` class for a token with [scopes] (innermost last), or `null`
/// for plain text.
String? tokenClassFor(List<String> scopes) {
  if (scopes.isEmpty) return null;
  final scope = scopes.last;
  if (scope.startsWith('comment')) return 'tk-comment';
  if (scope.startsWith('string')) return 'tk-string';
  if (scope.startsWith('constant.numeric')) return 'tk-number';
  if (scope.startsWith('storage.type.annotation')) return 'tk-annotation';
  if (scope.startsWith('support.class') || scope.startsWith('entity.name.type')) return 'tk-type';
  if (scope.startsWith('entity.name.function')) return 'tk-function';
  if (scope.startsWith('keyword.operator') || scope.startsWith('punctuation')) return null;
  if (scope.startsWith('keyword') ||
      scope.startsWith('storage') ||
      scope.startsWith('variable.language') ||
      scope.startsWith('constant.language')) {
    return 'tk-keyword';
  }
  return null;
}
