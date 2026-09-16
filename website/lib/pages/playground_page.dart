import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/footer.dart';
import '../components/navbar.dart';
import '../components/playground/playground_demo.dart';

class PlaygroundPage extends StatelessComponent {
  const PlaygroundPage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const Navbar(),
      main_(classes: 'wrap playground-page', [
        span(classes: 'section-kicker mono', [.text('// LIVE PLAYGROUND')]),
        h1(classes: 'section-title display', [.text('See It Rebuild, Live')]),
        p(classes: 'section-lede', [
          .text(
            'A real `KeyedFormController` — the same pure-Dart, zero-Flutter package the whole site talks about — driving plain HTML inputs right here in this page. Type into a field and watch its own rebuild counter move while every other field stays untouched. The panels on the right read the same controller live: the whole draft, the currently visible errors, and which fields have been touched.',
          ),
        ]),
        const PlaygroundDemo(),
      ]),
      const Footer(),
    ]);
  }
}
