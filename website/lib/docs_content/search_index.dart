import 'package:jaspr/jaspr.dart';

/// One searchable section: `title`, Markdown `section`, `docSection` and
/// `docSectionTitle`, plus `url` (base-prefixed with anchor) and plain `text`.
typedef SearchEntry = Map<String, String>;

/// The docs search index, built by `main.server.dart` from `content/docs/`.
class DocsSearchIndex extends InheritedComponent {
  const DocsSearchIndex({required this.entries, required super.child, super.key});

  final List<SearchEntry> entries;

  static List<SearchEntry> of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<DocsSearchIndex>()?.entries ?? const [];

  @override
  bool updateShouldNotify(DocsSearchIndex oldComponent) => oldComponent.entries != entries;
}
