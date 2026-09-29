import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'docs_menu_toggle.dart';

/// The dimmed backdrop behind the open chapters drawer; tapping it closes
/// the drawer.
@client
class DocsMenuBackdrop extends StatelessComponent {
  const DocsMenuBackdrop({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'md-backdrop', events: {'click': (_) => closeDocsMenu()}, []);
  }
}
