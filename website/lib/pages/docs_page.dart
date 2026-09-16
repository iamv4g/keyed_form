import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/docs/docs_sidebar.dart';
import '../components/docs/docs_toc.dart';
import '../components/docs/sections/benchmarks_doc.dart';
import '../components/docs/sections/core_guides_doc.dart';
import '../components/docs/sections/getting_started_doc.dart';
import '../components/docs/sections/recipes_doc.dart';
import '../components/docs/sections/reference_doc.dart';
import '../components/docs/sections/testing_doc.dart';
import '../components/docs/sections/virtualization_doc.dart';
import '../components/footer.dart';
import '../components/navbar.dart';

class DocsPage extends StatelessComponent {
  const DocsPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'docs-page', [
      const Navbar(),
      div(classes: 'docs-container', [
        div(classes: 'docs-layout', [
          const DocsSidebar(),
          main_(classes: 'docs-content', [
            const GettingStartedDoc(),
            const hr(classes: 'rule'),
            const CoreGuidesDoc(),
            const hr(classes: 'rule'),
            const VirtualizationDoc(),
            const hr(classes: 'rule'),
            const RecipesDoc(),
            const hr(classes: 'rule'),
            const TestingDoc(),
            const hr(classes: 'rule'),
            const ReferenceDoc(),
            const hr(classes: 'rule'),
            const BenchmarksDoc(),
          ]),
          const DocsToc(),
        ]),
      ]),
      const Footer(),
    ]);
  }
}
