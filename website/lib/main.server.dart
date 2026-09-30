/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'app.dart';
import 'base_path.dart';
import 'build_inputs.dart';
import 'code/highlight.dart';
import 'docs_content/docs_components.dart';
import 'docs_content/docs_layout.dart';
import 'docs_content/heading_anchors.dart';
import 'docs_content/search_index.dart';
import 'example_sources.dart';
import 'main.server.options.dart';
import 'package_versions.dart';

const _siteTitle = 'keyed_form — big Flutter forms, one rebuild per keystroke';
const _siteDescription =
    'Typed Flutter forms from one schema: each widget listens to its own slice of state, dynamic lists keep their identity across reorders, and form logic is plain Dart you can test without a widget tree.';
const _siteUrl = 'https://keyed-form.v4g.space/';
const _shareImageUrl = '${_siteUrl}images/logo.png';
const _shareImageAlt = 'keyed_form logo';

Future<void> main() async {
  await initHighlighter();

  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(
    Document(
      base: '$siteBasePath/',
      title: _siteTitle,
      lang: 'en',
      meta: {
        'description': _siteDescription,
        'twitter:card': 'summary',
        'twitter:title': _siteTitle,
        'twitter:description': _siteDescription,
        'twitter:image': _shareImageUrl,
        'twitter:image:alt': _shareImageAlt,
      },
      head: [
        meta(attributes: {'property': 'og:title', 'content': _siteTitle}),
        meta(attributes: {'property': 'og:description', 'content': _siteDescription}),
        meta(attributes: {'property': 'og:type', 'content': 'website'}),
        meta(attributes: {'property': 'og:url', 'content': _siteUrl}),
        meta(attributes: {'property': 'og:image', 'content': _shareImageUrl}),
        meta(attributes: {'property': 'og:image:alt', 'content': _shareImageAlt}),
        meta(attributes: {'property': 'og:image:width', 'content': '512'}),
        meta(attributes: {'property': 'og:image:height', 'content': '512'}),
        link(
          rel: 'icon',
          href: '$siteBasePath/favicon.ico',
          type: 'image/x-icon',
          attributes: {'sizes': '16x16 32x32 48x48'},
        ),
        link(
          rel: 'icon',
          href: '$siteBasePath/favicon.svg',
          type: 'image/svg+xml',
          attributes: {'sizes': 'any'},
        ),
        link(
          rel: 'apple-touch-icon',
          href: '$siteBasePath/apple-touch-icon.png',
          attributes: {'sizes': '180x180'},
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
      body: PackageVersions(
        versions: readPackageVersions(),
        child: DocsSearchIndex(
          entries: readDocsSearchIndex(),
          child: ExampleSources(
            files: readExampleSources(),
            child: ContentApp.custom(
              loaders: [FilesystemLoader('content')],
              configResolver: PageConfig.all(
                parsers: [MarkdownParser()],
                extensions: [TableOfContentsExtension(maxHeaderDepth: 2), const KfHeadingAnchors()],
                components: [
                  const KfCodeBlock(),
                  const ExampleCode(),
                  const PackingDemoTag(),
                  const PackageTopologyTag(),
                  const CapabilityMatrixTag(),
                  const Note(),
                ],
                layouts: [const KfDocsLayout()],
                secondaryOutputs: [MarkdownOutput(createHeader: pageMarkdownHeader)],
                theme: ContentTheme.none(),
              ),
              routerBuilder: (routes) => Router(routes: [...appRoutes, for (final r in routes) ...r]),
            ),
          ),
        ),
      ),
    ),
  );
}
