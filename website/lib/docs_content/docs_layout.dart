import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_lucide/jaspr_lucide.dart' as lucide;

import '../base_path.dart';
import '../components/docs/docs_menu_backdrop.dart';
import '../components/docs_header.dart';
import '../components/footer.dart';
import '../components/icons.dart';
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
      const DocsHeader(section: 'docs', hasSidebar: true),
      div(classes: 'docs-shell docs-body', [
        _Sidebar(current: page.url),
        div(classes: 'docs-main', [
          main_(classes: 'docs-article md-content', [
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
            if (tocEntries != null)
              div(classes: 'docs-toc-inner', [
                div(classes: 'docs-toc-header', [.text('On this page')]),
                div(classes: 'md-toc', [_toc(tocEntries.entries, page.url)]),
              ]),
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

// Saves the list's scroll offset when one of its links is clicked and
// restores it on the next page. Without a saved offset (direct visit,
// reload), scrolls the current page's item into view if it is hidden.
const _keepScroll = '''
(function () {
  var nav = document.currentScript.parentElement.querySelector('.md-sidebar-scroll');
  var key = 'kf-sidebar-scroll';
  try {
    var saved = sessionStorage.getItem(key);
    sessionStorage.removeItem(key);
    if (saved !== null) {
      nav.scrollTop = +saved;
    } else {
      var item = nav.querySelector('.md-sidebar-item.active');
      if (item) {
        var r = item.getBoundingClientRect(), n = nav.getBoundingClientRect();
        if (r.top < n.top || r.bottom > n.bottom) nav.scrollTop += r.top - n.top - (n.height - r.height) / 2;
      }
    }
    nav.addEventListener('click', function (e) {
      if (e.target.closest('a')) sessionStorage.setItem(key, String(nav.scrollTop));
    });
  } catch (_) {}
})();
''';

/// The chapters list: a sticky column on wide screens, a drawer from the
/// left (opened from the header's tab row) on narrow ones. Site links sit on
/// top, then one labelled group per chapter.
class _Sidebar extends StatelessComponent {
  const _Sidebar({required this.current});

  final String current;

  @override
  Component build(BuildContext context) {
    final groups = {for (final entry in docsPages) entry.group};
    return div(classes: 'md-sidebar', [
      const DocsMenuBackdrop(),
      aside(classes: 'md-sidebar-panel', [
        div(classes: 'md-sidebar-fade top', []),
        div(classes: 'md-sidebar-fade bottom', []),
        nav(
          classes: 'md-sidebar-scroll',
          attributes: {'aria-label': 'Documentation'},
          [
            ul(classes: 'md-sidebar-links', [
              _siteLink('Website', '$siteBasePath/', lucide.Globe(width: 16.px, height: 16.px)),
              _siteLink('Playground', '$siteBasePath/playground', lucide.Code(width: 16.px, height: 16.px)),
            ]),
            div(classes: 'md-separator', []),
            for (final (i, group) in groups.indexed)
              div(classes: 'md-group', [
                if (i > 0) div(classes: 'md-group-separator', []),
                div(classes: 'md-group-label', [.text(group)]),
                ul(classes: 'md-group-items', [
                  for (final entry in docsPages.where((e) => e.group == group)) _item(entry),
                ]),
              ]),
          ],
        ),
        // Pages are separate documents, so the list would reopen at the top.
        // Runs while the page parses, before the first paint.
        script(content: _keepScroll),
      ]),
    ]);
  }

  static Component _siteLink(String label, String href, Component icon) {
    return li([
      a(classes: 'md-sidebar-link', href: href, [
        span(classes: 'md-sidebar-icon', [icon]),
        span([.text(label)]),
      ]),
    ]);
  }

  Component _item(DocsEntry entry) {
    final active = entry.path == current;
    return li([
      a(
        classes: active ? 'md-sidebar-item active' : 'md-sidebar-item',
        href: '$siteBasePath${entry.path}',
        attributes: {if (active) 'aria-current': 'page'},
        [
          _icon(entry.icon),
          span([.text(entry.title)]),
        ],
      ),
    ]);
  }

  static Component _icon(String name) {
    final size = 16.px;
    return switch (name) {
      'book-open' => lucide.BookOpen(width: size, height: size),
      'download' => lucide.Download(width: size, height: size),
      'rocket' => lucide.Rocket(width: size, height: size),
      'workflow' => lucide.Workflow(width: size, height: size),
      'package' => lucide.Package(width: size, height: size),
      'sliders-horizontal' => lucide.SlidersHorizontal(width: size, height: size),
      'text-cursor-input' => lucide.TextCursorInput(width: size, height: size),
      'shield-check' => lucide.ShieldCheck(width: size, height: size),
      'hourglass' => lucide.Hourglass(width: size, height: size),
      'link' => lucide.Link(width: size, height: size),
      'grip-vertical' => lucide.GripVertical(width: size, height: size),
      'list' => lucide.List(width: size, height: size),
      'arrow-down-to-line' => lucide.ArrowDownToLine(width: size, height: size),
      'list-checks' => lucide.ListChecks(width: size, height: size),
      'server-crash' => lucide.ServerCrash(width: size, height: size),
      'list-tree' => lucide.ListTree(width: size, height: size),
      'toggle-right' => lucide.ToggleRight(width: size, height: size),
      'split' => lucide.Split(width: size, height: size),
      'flask-conical' => lucide.FlaskConical(width: size, height: size),
      'file-code' => lucide.FileCode(width: size, height: size),
      'arrow-right-left' => lucide.ArrowRightLeft(width: size, height: size),
      'circle-question-mark' => lucide.CircleQuestionMark(width: size, height: size),
      'gauge' => lucide.Gauge(width: size, height: size),
      _ => throw ArgumentError.value(name, 'icon', 'No sidebar icon with this name'),
    };
  }
}
