import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/docs_page.dart';
import 'pages/landing_page.dart';
import 'pages/playground_page.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: '/',
          title: 'keyed_form — big Flutter forms, one rebuild per keystroke',
          builder: (context, state) => const LandingPage(),
        ),
        Route(
          path: '/docs',
          title: 'Documentation · keyed_form',
          builder: (context, state) => const DocsPage(),
        ),
        Route(
          path: '/playground',
          title: 'Playground · keyed_form',
          builder: (context, state) => const PlaygroundPage(),
        ),
      ],
    );
  }
}
