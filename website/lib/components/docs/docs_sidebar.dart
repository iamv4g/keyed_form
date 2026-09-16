import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../base_path.dart';
import 'docs_nav_data.dart';

@client
class DocsSidebar extends StatefulComponent {
  const DocsSidebar({super.key});

  @override
  State<DocsSidebar> createState() => _DocsSidebarState();
}

class _DocsSidebarState extends State<DocsSidebar> {
  String _query = '';

  @override
  Component build(BuildContext context) {
    final lowerQuery = _query.trim().toLowerCase();

    return aside(classes: 'docs-sidebar', [
      div(classes: 'docs-search-box', [
        input(
          classes: 'docs-search-input mono',
          type: InputType.text,
          value: _query,
          attributes: {
            'placeholder': 'Quick filter docs...',
            'aria-label': 'Filter documentation topics',
          },
          onInput: (val) {
            setState(() {
              _query = val.toString();
            });
          },
        ),
      ]),
      nav(classes: 'docs-sidebar-nav', [
        for (final group in docsNavGroups) ...[
          () {
            final matchingItems = group.items.where((item) {
              if (lowerQuery.isEmpty) return true;
              return item.title.toLowerCase().contains(lowerQuery) ||
                  (item.badge?.toLowerCase().contains(lowerQuery) ?? false) ||
                  group.kicker.toLowerCase().contains(lowerQuery);
            }).toList();

            if (matchingItems.isEmpty) return const Component.empty();

            return div(classes: 'docs-nav-group', [
              div(classes: 'docs-nav-group-title mono', [.text(group.kicker)]),
              ul(classes: 'docs-nav-list', [
                for (final item in matchingItems)
                  li(classes: 'docs-nav-item', [
                    a(classes: 'docs-nav-link', href: '$siteBasePath/docs${item.href}', [
                      span(classes: 'nav-title', [.text(item.title)]),
                      if (item.badge case final badge?) span(classes: 'nav-badge mono', [.text(badge)]),
                    ]),
                  ]),
              ]),
            ]);
          }(),
        ],
      ]),
    ]);
  }
}
