/// One Markdown docs page, in sidebar order.
class DocsEntry {
  const DocsEntry(this.group, this.title, this.slug);

  final String group;
  final String title;

  /// File name under `content/docs/` without `.md`; `index` is `/docs`.
  final String slug;

  String get path => slug == 'index' ? '/docs' : '/docs/$slug';
}

/// Sidebar order, eyebrows and Prev/Next all come from this list; a test
/// keeps it in step with the files under `content/docs/`.
const docsPages = <DocsEntry>[
  DocsEntry('Getting started', 'Introduction', 'introduction'),
  DocsEntry('Getting started', 'Installation', 'installation'),
  DocsEntry('Getting started', 'Quickstart', 'quickstart'),
  DocsEntry('Getting started', 'How it works', 'how-it-works'),
  DocsEntry('Core concepts', 'Packages', 'packages'),
  DocsEntry('Core concepts', 'Controller', 'controller'),
  DocsEntry('Core concepts', 'Field handles', 'field-handles'),
  DocsEntry('Core concepts', 'Validation', 'validation'),
  DocsEntry('Core concepts', 'Async validation', 'async-validation'),
  DocsEntry('Core concepts', 'Relations', 'relations'),
  DocsEntry('Lists & scrolling', 'Dynamic lists', 'dynamic-lists'),
];
