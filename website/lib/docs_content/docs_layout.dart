import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../base_path.dart';
import '../components/footer.dart';
import '../components/navbar.dart';
import 'docs_nav.dart';

/// Renders a Markdown page inside the site's own `Document` (it is a
/// [PageLayout], not a `PageLayoutBase`, so it doesn't open a second one).
class KfDocsLayout implements PageLayout {
  const KfDocsLayout();

  @override
  Pattern get name => 'docs';

  @override
  Component buildLayout(Page page, Component child) {
    final data = page.data.page;
    final title = data['title'] as String?;
    final description = data['description'] as String?;
    final group = docsPages.where((entry) => entry.path == page.url).firstOrNull?.group;
    final toc = page.data['toc'];

    return div(classes: 'docs-page', [
      Document.head(
        title: title == null ? 'Documentation · keyed_form' : '$title · keyed_form',
        meta: {'description': ?description},
      ),
      const Navbar(),
      div(classes: 'docs-container', [
        div(classes: 'docs-layout md-layout', [
          const _Sidebar(),
          main_(classes: 'md-content', [
            if (group != null) span(classes: 'md-eyebrow', [.text(group)]),
            if (title != null) h1([.text(title)]),
            if (description != null) p(classes: 'md-lead', [.text(description)]),
            child,
          ]),
          aside(classes: 'docs-toc', [
            if (toc is TableOfContents && toc.entries.isNotEmpty) ...[
              div(classes: 'docs-toc-header mono', [.text('ON THIS PAGE')]),
              div(classes: 'md-toc', [toc.build()]),
            ],
          ]),
        ]),
      ]),
      const Footer(),
    ]);
  }
}

class _Sidebar extends StatelessComponent {
  const _Sidebar();

  @override
  Component build(BuildContext context) {
    final current = RouteState.of(context).path;
    final groups = {for (final entry in docsPages) entry.group};
    return nav(classes: 'md-sidebar', [
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
    ]);
  }
}
