/// One documentation track, which owns a root, sidebar and reading order.
enum DocsSection {
  guides('guides', 'Guides', 'guides'),
  schema('schema', 'Schema', 'schema'),
  formState('form-state', 'Form State', 'form-state'),
  flutter('flutter', 'Flutter', 'flutter'),
  docs('docs', 'Docs', '');

  const DocsSection(this.id, this.label, this.directory);
  final String id;
  final String label;
  final String directory;
  String get path => directory.isEmpty ? '/docs' : '/docs/$directory';
  bool get searchable => this != DocsSection.docs;
}

const docsSections = DocsSection.values;

/// One Markdown docs page in its section's sidebar order.
class DocsEntry {
  const DocsEntry(this.section, this.group, this.title, this.slug, this.icon);

  final DocsSection section;
  final String group;
  final String title;

  /// Lucide icon name shown beside the title in the sidebar.
  final String icon;

  /// File name without `.md`; `index` maps to its section root.
  final String slug;

  String get path => slug == 'index' ? section.path : '${section.path}/$slug';
  String get contentPath =>
      'docs/${section.directory.isEmpty ? '' : '${section.directory}/'}$slug.md';
}

/// Sidebar order and Prev/Next all come from this list.
const docsPages = <DocsEntry>[
  DocsEntry(DocsSection.guides, 'Getting started', 'Guides', 'index', 'book-open'),
  DocsEntry(DocsSection.guides, 'Getting started', 'Installation', 'installation', 'file-code'),
  DocsEntry(DocsSection.guides, 'Getting started', 'Quickstart', 'quickstart', 'file-code'),
  DocsEntry(DocsSection.guides, 'Getting started', 'How it works', 'how-it-works', 'file-code'),
  DocsEntry(DocsSection.guides, 'Getting started', 'Packages', 'packages', 'package'),
  DocsEntry(DocsSection.guides, 'Recipes', 'Dynamic lists', 'dynamic-lists', 'grip-vertical'),
  DocsEntry(DocsSection.guides, 'Recipes', 'Multi-step forms', 'wizard', 'list-checks'),
  DocsEntry(DocsSection.guides, 'Recipes', 'Cascading dropdowns', 'cascading-dropdowns', 'list-tree'),
  DocsEntry(DocsSection.guides, 'Quality', 'Testing', 'testing', 'flask-conical'),
  DocsEntry(DocsSection.guides, 'Reference', 'API reference', 'api-reference', 'file-code'),
  DocsEntry(DocsSection.guides, 'Reference', 'Migration', 'migration', 'arrow-right-left'),
  DocsEntry(DocsSection.guides, 'Reference', 'FAQ', 'faq', 'circle-question-mark'),
  DocsEntry(DocsSection.guides, 'Reference', 'Benchmarks', 'benchmarks', 'gauge'),
  DocsEntry(DocsSection.schema, 'Fundamentals', 'Schema', 'index', 'book-open'),
  DocsEntry(DocsSection.schema, 'Fundamentals', 'Builders and rules', 'builders', 'file-code'),
  DocsEntry(DocsSection.schema, 'Fundamentals', 'Objects and collections', 'composition', 'file-code'),
  DocsEntry(DocsSection.schema, 'Validation', 'Refinements and async validation', 'refinements', 'file-code'),
  DocsEntry(DocsSection.schema, 'Validation', 'Errors and localization', 'errors', 'file-code'),
  DocsEntry(DocsSection.schema, 'Modeling', 'Discriminated unions', 'unions', 'file-code'),
  DocsEntry(DocsSection.schema, 'Generation', 'Code generation', 'code-generation', 'file-code'),
  DocsEntry(DocsSection.formState, 'Fundamentals', 'Form State', 'index', 'book-open'),
  DocsEntry(DocsSection.formState, 'Fundamentals', 'Controller and lifecycle', 'controller', 'file-code'),
  DocsEntry(DocsSection.formState, 'Fundamentals', 'Field handles', 'field-handles', 'text-cursor-input'),
  DocsEntry(DocsSection.formState, 'Validation', 'Validation and visibility', 'validation', 'file-code'),
  DocsEntry(DocsSection.formState, 'Validation', 'Async validation', 'async-validation', 'hourglass'),
  DocsEntry(DocsSection.formState, 'Validation', 'Server errors', 'server-errors', 'server-crash'),
  DocsEntry(DocsSection.formState, 'Collections and relations', 'List operations', 'lists', 'file-code'),
  DocsEntry(DocsSection.formState, 'Collections and relations', 'Relations', 'relations', 'link'),
  DocsEntry(DocsSection.formState, 'Reference', 'Form State API', 'api-reference', 'file-code'),
  DocsEntry(DocsSection.flutter, 'Getting started', 'Flutter', 'index', 'book-open'),
  DocsEntry(DocsSection.flutter, 'Bindings', 'Form scope and context', 'form-context', 'file-code'),
  DocsEntry(DocsSection.flutter, 'Bindings', 'Field bindings and custom controls', 'field-bindings', 'file-code'),
  DocsEntry(DocsSection.flutter, 'Bindings', 'Text fields and bindings', 'text-binding', 'file-code'),
  DocsEntry(DocsSection.flutter, 'Reactivity', 'Selective rebuilds', 'reactivity', 'file-code'),
  DocsEntry(DocsSection.flutter, 'Lists and submission', 'Lists and virtualization', 'long-lists', 'list'),
  DocsEntry(DocsSection.flutter, 'Lists and submission', 'Submit and scroll to error', 'scroll-to-first-error', 'arrow-down-to-line'),
  DocsEntry(DocsSection.flutter, 'Recipes', 'Rendering union fields', 'unions', 'file-code'),
  DocsEntry(DocsSection.flutter, 'Reference', 'Flutter API', 'api-reference', 'file-code'),
  DocsEntry(DocsSection.docs, 'Getting started', 'Introduction', 'index', 'book-open'),
  DocsEntry(DocsSection.docs, 'Getting started', 'Installation', 'installation', 'download'),
  DocsEntry(DocsSection.docs, 'Getting started', 'Quickstart', 'quickstart', 'rocket'),
  DocsEntry(DocsSection.docs, 'Getting started', 'How it works', 'how-it-works', 'workflow'),
  DocsEntry(DocsSection.docs, 'Core concepts', 'Packages', 'packages', 'package'),
  DocsEntry(DocsSection.docs, 'Core concepts', 'Controller', 'controller', 'sliders-horizontal'),
  DocsEntry(DocsSection.docs, 'Core concepts', 'Field handles', 'field-handles', 'text-cursor-input'),
  DocsEntry(DocsSection.docs, 'Core concepts', 'Validation', 'validation', 'shield-check'),
  DocsEntry(DocsSection.docs, 'Core concepts', 'Async validation', 'async-validation', 'hourglass'),
  DocsEntry(DocsSection.docs, 'Core concepts', 'Relations', 'relations', 'link'),
  DocsEntry(DocsSection.docs, 'Lists & scrolling', 'Dynamic lists', 'dynamic-lists', 'grip-vertical'),
  DocsEntry(DocsSection.docs, 'Lists & scrolling', 'Long lists', 'long-lists', 'list'),
  DocsEntry(DocsSection.docs, 'Lists & scrolling', 'Scroll to first error', 'scroll-to-first-error', 'arrow-down-to-line'),
  DocsEntry(DocsSection.docs, 'Recipes', 'Multi-step forms', 'wizard', 'list-checks'),
  DocsEntry(DocsSection.docs, 'Recipes', 'Server errors', 'server-errors', 'server-crash'),
  DocsEntry(DocsSection.docs, 'Recipes', 'Cascading dropdowns', 'cascading-dropdowns', 'list-tree'),
  DocsEntry(DocsSection.docs, 'Recipes', 'Custom controls', 'custom-controls', 'toggle-right'),
  DocsEntry(DocsSection.docs, 'Recipes', 'Discriminated unions', 'unions', 'split'),
  DocsEntry(DocsSection.docs, 'Testing', 'Testing', 'testing', 'flask-conical'),
  DocsEntry(DocsSection.docs, 'Reference', 'API reference', 'api-reference', 'file-code'),
  DocsEntry(DocsSection.docs, 'Reference', 'Migration', 'migration', 'arrow-right-left'),
  DocsEntry(DocsSection.docs, 'Reference', 'FAQ', 'faq', 'circle-question-mark'),
  DocsEntry(DocsSection.docs, 'Reference', 'Benchmarks', 'benchmarks', 'gauge'),
];

List<DocsEntry> docsPagesFor(DocsSection section) =>
    docsPages.where((page) => page.section == section).toList(growable: false);

DocsEntry docsPageForPath(String path) => docsPages.firstWhere((page) => page.path == path);
