import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../base_path.dart';
import '../components/docs/docs_menu_backdrop.dart';
import '../components/footer.dart';
import '../components/navbar.dart';
import 'docs_nav.dart';

const _editBase = 'https://github.com/iamv4g/keyed_form/edit/main/website/content/';

/// Renders a Markdown page inside the site's own `Document` (a [PageLayout],
/// not a `PageLayoutBase`, so it doesn't open a second one).
class KfDocsLayout implements PageLayout {
  const KfDocsLayout();

  @override
  Pattern get name => 'docs';

  @override
  Component buildLayout(Page page, Component child) {
    final data = page.data.page;
    final title = data['title'] as String?;
    final description = data['description'] as String?;
    final index = docsPages.indexWhere((entry) => entry.path == page.url);
    final entry = index < 0 ? null : docsPages[index];
    final prev = index > 0 ? docsPages[index - 1] : null;
    final next = index >= 0 && index < docsPages.length - 1 ? docsPages[index + 1] : null;
    final toc = page.data['toc'];
    final tocEntries = toc is TableOfContents && toc.entries.isNotEmpty ? toc : null;

    return div(classes: 'docs-page', [
      Document.head(
        title: title == null ? 'Documentation · keyed_form' : '$title · keyed_form',
        meta: {'description': ?description},
      ),
      const Navbar(showDocsMenuToggle: true),
      div(classes: 'docs-container', [
        div(classes: 'docs-layout md-layout', [
          _Sidebar(current: page.url),
          main_(classes: 'md-content', [
            if (entry != null) span(classes: 'md-eyebrow', [.text(entry.group)]),
            if (title != null) h1([.text(title)]),
            if (description != null) p(classes: 'md-lead', [.text(description)]),
            if (tocEntries != null)
              details(classes: 'md-toc-mobile', [
                summary([.text('On this page')]),
                _toc(tocEntries.entries, page.url),
              ]),
            child,
            div(classes: 'md-page-footer', [
              nav(classes: 'md-pager', [
                if (prev != null) _pagerLink(prev, 'Previous', 'prev') else span([]),
                if (next != null) _pagerLink(next, 'Next', 'next'),
              ]),
              a(classes: 'md-edit', href: '$_editBase${page.path}', target: Target.blank, [
                .text('Edit this page on GitHub ↗'),
              ]),
            ]),
          ]),
          aside(classes: 'docs-toc', [
            if (tocEntries != null) ...[
              div(classes: 'docs-toc-header mono', [.text('ON THIS PAGE')]),
              div(classes: 'md-toc', [_toc(tocEntries.entries, page.url)]),
            ],
          ]),
        ]),
      ]),
      const Footer(),
    ]);
  }

  // Links carry the base path: a bare `#id` would resolve against <base>.
  static Component _toc(List<TocEntry> entries, String url) => ul([
    for (final entry in entries)
      li([
        a(href: '$siteBasePath$url#${entry.id}', [.text(entry.text)]),
        if (entry.children.isNotEmpty) _toc(entry.children, url),
      ]),
  ]);

  static Component _pagerLink(DocsEntry entry, String label, String classes) {
    return a(classes: 'md-pager-link $classes', href: '$siteBasePath${entry.path}', [
      span(classes: 'md-pager-label', [.text(label)]),
      span(classes: 'md-pager-title', [.text(entry.title)]),
    ]);
  }
}

/// The chapters list: a sticky column on desktop, a drawer (opened by the
/// navbar's ☰) on phones.
class _Sidebar extends StatelessComponent {
  const _Sidebar({required this.current});

  final String current;

  @override
  Component build(BuildContext context) {
    final groups = {for (final entry in docsPages) entry.group};
    return div(classes: 'docs-sidebar md-sidebar', [
      const DocsMenuBackdrop(),
      aside(classes: 'docs-sidebar-panel', [
        nav([
          for (final group in groups) ...[
            div(classes: 'md-sidebar-group', [.text(group)]),
            ul([
              for (final entry in docsPages.where((e) => e.group == group))
                li([
                  a(
                    classes: entry.path == current ? 'active' : null,
                    href: '$siteBasePath${entry.path}',
                    [.text(entry.title)],
                  ),
                ]),
            ]),
          ],
        ]),
      ]),
    ]);
  }
}
