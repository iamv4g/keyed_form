/// One Markdown docs page, in sidebar order.
class DocsEntry {
  const DocsEntry(this.group, this.title, this.slug, this.icon);

  final String group;
  final String title;

  /// Lucide icon name shown beside the title in the sidebar.
  final String icon;

  /// File name under `content/docs/` without `.md`; `index` is `/docs`.
  final String slug;

  String get path => slug == 'index' ? '/docs' : '/docs/$slug';
}

/// Sidebar order and Prev/Next all come from this list; a test
/// keeps it in step with the files under `content/docs/`.
const docsPages = <DocsEntry>[
  DocsEntry('Getting started', 'Introduction', 'index', 'book-open'),
  DocsEntry('Getting started', 'Installation', 'installation', 'download'),
  DocsEntry('Getting started', 'Quickstart', 'quickstart', 'rocket'),
  DocsEntry('Getting started', 'How it works', 'how-it-works', 'workflow'),
  DocsEntry('Core concepts', 'Packages', 'packages', 'package'),
  DocsEntry('Core concepts', 'Controller', 'controller', 'sliders-horizontal'),
  DocsEntry('Core concepts', 'Field handles', 'field-handles', 'text-cursor-input'),
  DocsEntry('Core concepts', 'Validation', 'validation', 'shield-check'),
  DocsEntry('Core concepts', 'Async validation', 'async-validation', 'hourglass'),
  DocsEntry('Core concepts', 'Relations', 'relations', 'link'),
  DocsEntry('Lists & scrolling', 'Dynamic lists', 'dynamic-lists', 'grip-vertical'),
  DocsEntry('Lists & scrolling', 'Long lists', 'long-lists', 'list'),
  DocsEntry('Lists & scrolling', 'Scroll to first error', 'scroll-to-first-error', 'arrow-down-to-line'),
  DocsEntry('Recipes', 'Multi-step forms', 'wizard', 'list-checks'),
  DocsEntry('Recipes', 'Server errors', 'server-errors', 'server-crash'),
  DocsEntry('Recipes', 'Cascading dropdowns', 'cascading-dropdowns', 'list-tree'),
  DocsEntry('Recipes', 'Custom controls', 'custom-controls', 'toggle-right'),
  DocsEntry('Recipes', 'Discriminated unions', 'unions', 'split'),
  DocsEntry('Testing', 'Testing', 'testing', 'flask-conical'),
  DocsEntry('Reference', 'API reference', 'api-reference', 'file-code'),
  DocsEntry('Reference', 'Migration', 'migration', 'arrow-right-left'),
  DocsEntry('Reference', 'FAQ', 'faq', 'circle-question-mark'),
  DocsEntry('Reference', 'Benchmarks', 'benchmarks', 'gauge'),
];
