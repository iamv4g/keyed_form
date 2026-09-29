/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'dart:io';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'base_path.dart';
import 'code/highlight.dart';
import 'main.server.options.dart';
import 'package_versions.dart';

Future<void> main() async {
  await initHighlighter();

  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(
    Document(
      base: '$siteBasePath/',
      title: 'keyed_form — big Flutter forms, one rebuild per keystroke',
      lang: 'en',
      meta: {
        'description':
            'Typed Flutter forms from one schema: each widget listens to its own slice of state, dynamic lists keep their identity across reorders, and form logic is plain Dart you can test without a widget tree.',
        'og:title': 'keyed_form — big Flutter forms, one rebuild per keystroke',
        'og:description':
            'Typed Flutter forms from one schema: each widget listens to its own slice of state, dynamic lists keep their identity across reorders, and form logic is plain Dart you can test without a widget tree.',
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
      body: PackageVersions(versions: _readPackageVersions(), child: const App()),
    ),
  );
}

/// `name → version` from `../packages/*/pubspec.yaml` (builds run in `website/`).
Map<String, String> _readPackageVersions() {
  final packages = Directory('../packages');
  if (!packages.existsSync()) return const {};
  final name = RegExp(r'^name:\s*(\S+)', multiLine: true);
  final version = RegExp(r'^version:\s*(\S+)', multiLine: true);
  final versions = <String, String>{};
  for (final dir in packages.listSync().whereType<Directory>()) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (!pubspec.existsSync()) continue;
    final text = pubspec.readAsStringSync();
    final n = name.firstMatch(text)?.group(1);
    final v = version.firstMatch(text)?.group(1);
    if (n != null && v != null) versions[n] = v;
  }
  return versions;
}
