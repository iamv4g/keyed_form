/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'base_path.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(
    Document(
      base: '$siteBasePath/',
      title: 'keyed_form — typed, O(1) Flutter forms built on keyed optics',
      lang: 'en',
      meta: {
        'description':
            "keyed_form gives every field a stable, typed, serializable identity — dynamic lists survive reorders, rebuilds stay O(1) at any form size, and a form's state is a plain immutable value you can test without a widget.",
        'og:title': 'keyed_form — typed, O(1) Flutter forms on keyed optics',
        'og:description':
            'Typed, O(1) Flutter forms built on keyed optics. Verified in a reproducible open-source benchmark harness against three alternative Flutter form architectures — string-keyed controllers, declarative builders, and sealed-state validators.',
        'og:type': 'website',
        'og:url': 'https://iamv4g.github.io/keyed_form/',
        'twitter:card': 'summary_large_image',
      },
      head: [
        link(
          rel: 'icon',
          href:
              "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2300F0FF' stroke-width='2'><circle cx='12' cy='12' r='8'/><circle cx='12' cy='12' r='3' fill='%2300F0FF'/><line x1='12' y1='2' x2='12' y2='4'/><line x1='12' y1='20' x2='12' y2='22'/><line x1='2' y1='12' x2='4' y2='12'/><line x1='20' y1='12' x2='22' y2='12'/></svg>",
        ),
        link(rel: 'preconnect', href: 'https://fonts.googleapis.com'),
        link(
          rel: 'preconnect',
          href: 'https://fonts.gstatic.com',
          attributes: {'crossorigin': ''},
        ),
        link(
          rel: 'stylesheet',
          href:
              'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600;700&family=Inter:wght@400;500;600&display=swap',
        ),
        script(
          content:
              "try{var t=localStorage.getItem('theme');if(t)document.documentElement.setAttribute('data-theme',t);}catch(e){}",
        ),
      ],
      body: const App(),
    ),
  );
}
