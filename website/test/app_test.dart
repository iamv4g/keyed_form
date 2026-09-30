import 'dart:io';

import 'package:jaspr/jaspr.dart' show JasprBadge;
import 'package:jaspr_test/jaspr_test.dart';
import 'package:website/code/code_tabs.dart';
import 'package:website/build_inputs.dart';
import 'package:website/code/highlight.dart';
import 'package:website/components/agent_skill_section.dart';
import 'package:website/components/demo/hero_login_demo.dart';
import 'package:website/components/docs/package_topology.dart';
import 'package:website/components/docs_header.dart';
import 'package:website/components/feature_grid.dart';
import 'package:website/components/footer.dart';
import 'package:website/components/hero_section.dart';
import 'package:website/components/lists_section.dart';
import 'package:website/components/model_section.dart';
import 'package:website/components/telemetry_section.dart';
import 'package:website/components/navbar.dart';
import 'package:website/docs_content/docs_nav.dart';
import 'package:website/docs_content/search_index.dart';
import 'package:website/example_sources.dart';
import 'package:website/pages/landing_page.dart';
import 'package:website/package_versions.dart';

String _builtBasePrefix() {
  final html = File('build/jaspr/index.html').readAsStringSync();
  final href = RegExp(r'<base href="([^"]+)"/>').firstMatch(html)!.group(1)!;
  return Uri.parse(href).path.replaceFirst(RegExp(r'/$'), '');
}

String _siteRoute(String path) => '${_builtBasePrefix()}$path';

void main() {
  setUpAll(initHighlighter);

  group('Website Component Tests', () {
    testComponents('renders full App with all landing page sections', (
      tester,
    ) async {
      tester.pumpComponent(ExampleSources(files: readExampleSources(), child: const LandingPage()));

      // Brand & Navigation
      expect(find.textContaining('keyed_form'), findsComponents);
      expect(find.text('Docs'), findsComponents); // navbar + footer column
      expect(find.text('Playground'), findsComponents);

      // Section Kickers
      expect(find.text('// FEATURES'), findsOneComponent);
      expect(find.text('// MEASURED'), findsOneComponent);
      expect(find.text('// THE MODEL'), findsOneComponent);
      expect(find.text('// AGENT SKILL'), findsOneComponent);
      expect(find.text('// DYNAMIC LISTS'), findsOneComponent);

      // Closing CTA + footer
      expect(find.text('Your next form is one schema away.'), findsOneComponent);
      expect(find.text('Typed Flutter forms, one rebuild per keystroke.'), findsOneComponent);
    });

    testComponents('Navbar renders brand, text links, icon links and ThemeToggle', (tester) async {
      tester.pumpComponent(const Navbar());

      expect(find.textContaining('keyed_form'), findsOneComponent);
      expect(find.text('Docs'), findsOneComponent);
      expect(find.text('Playground'), findsOneComponent);
      // In-page anchors are gone from the header.
      expect(find.text('Invariants'), findsNothing);
      expect(find.text('Architecture'), findsNothing);
      // pub.dev / GitHub are icon-only links, labelled for screen readers.
      expect(find.tag('svg'), findsComponents);
      expect(find.text('pub.dev ↗'), findsNothing);
      expect(find.text('GitHub ↗'), findsNothing);
      expect(find.tag('button'), findsOneComponent);
    });

    testComponents('ModelSection shows the three login files, the demo and the points', (tester) async {
      tester.pumpComponent(ExampleSources(files: readExampleSources(), child: const ModelSection()));

      expect(find.text('// THE MODEL'), findsOneComponent);
      for (final file in ['login_schema.dart', 'login_form.dart', 'login_text_field.dart']) {
        expect(find.text(file), findsOneComponent);
      }
      expect(find.text('Run the example'), findsOneComponent);
      expect(find.text('// WATCH — form.value.toMap()'), findsOneComponent);
      expect(find.text('// ERRORS — form.visibleErrorKeys'), findsOneComponent);
      expect(find.text('Sign in'), findsOneComponent);
      expect(find.text('Quickstart in 5 minutes →'), findsOneComponent);
    });

    testComponents('AgentSkillSection installs into .agents/skills and links it for Claude Code', (tester) async {
      tester.pumpComponent(const AgentSkillSection());

      expect(find.text('// AGENT SKILL'), findsOneComponent);
      expect(find.textContaining('-o .agents/skills/keyed_form/SKILL.md'), findsOneComponent);
      expect(
        find.text('mkdir -p .claude/skills && ln -s ../../.agents/skills/keyed_form .claude/skills/keyed_form'),
        findsOneComponent,
      );
      expect(find.text('COPY'), findsNComponents(2));
      expect(find.text('Read SKILL.md →'), findsOneComponent);
    });

    testComponents('ListsSection shows the packing files, the demo rows and the dnd_kit credit', (tester) async {
      tester.pumpComponent(ExampleSources(files: readExampleSources(), child: const ListsSection()));

      expect(find.text('// DYNAMIC LISTS'), findsOneComponent);
      for (final file in ['packing_schema.dart', 'packing_list.dart', 'packing_row.dart']) {
        expect(find.text(file), findsOneComponent);
      }
      expect(find.text('// ROWS — index · clientId · label'), findsOneComponent);
      expect(find.text('⠿'), findsNComponents(3));
      expect(find.text('dnd_kit'), findsOneComponent);
    });

    testComponents('TelemetrySection shows flat rebuilds without comparing against anything', (tester) async {
      tester.pumpComponent(const TelemetrySection());

      expect(find.text('// MEASURED'), findsOneComponent);
      expect(find.text('44'), findsNComponents(4));
      for (final size in [10, 50, 100, 250]) {
        expect(find.text('$size fields'), findsOneComponent);
      }
      expect(find.text('~2 µs'), findsOneComponent);
      expect(find.text('6,021'), findsNothing);
      expect(find.text('0.00µs'), findsNothing);
    });

    testComponents('FeatureGrid renders nine linked cards', (tester) async {
      tester.pumpComponent(const FeatureGrid());

      expect(find.text('// FEATURES'), findsOneComponent);
      expect(find.tag('a'), findsNComponents(9));
      for (final api in [
        'validateAsync',
        'addRelation',
        'markReadOnly',
        'revealFirst',
        'handleSubmit',
        'setServerErrors',
      ]) {
        expect(find.text(api), findsOneComponent);
      }
    });

    testComponents('Footer has three link columns and both Jaspr badge variants', (tester) async {
      tester.pumpComponent(const Footer());

      for (final title in ['Project', 'Docs', 'Resources']) {
        expect(find.text(title), findsOneComponent);
      }
      for (final link in ['Changelog', 'Issues', 'API reference', 'Quickstart', 'Playground']) {
        expect(find.text(link), findsOneComponent);
      }
      expect(find.byType(JasprBadge), findsNComponents(2));
      expect(find.textContaining('v0.'), findsNothing);
    });

    testComponents('PackageTopology shows each package with its own version', (tester) async {
      tester.pumpComponent(
        const PackageVersions(
          versions: {'keyed_form_gen': '0.2.0', 'keyed_form_flutter': '0.1.0'},
          child: PackageTopology(),
        ),
      );

      expect(find.text('keyed_form_gen'), findsOneComponent);
      expect(find.text('v0.2.0'), findsOneComponent);
      expect(find.text('v0.1.0'), findsOneComponent);
      // No version known → no chip, rather than a wrong one.
      expect(find.text('keyed_lens'), findsOneComponent);
      expect(find.textContaining(RegExp(r'^v\d')), findsNComponents(2));
    });

    testComponents('DocsHeader renders all section destinations and active section label', (tester) async {
      tester.pumpComponent(
        DocsSearchIndex(
          entries: readDocsSearchIndex(),
          child: const DocsHeader(section: DocsSection.schema),
        ),
      );

      expect(find.text('Search'), findsOneComponent);
      for (final label in ['Guides', 'Schema', 'Form State', 'Flutter', 'Docs']) {
        expect(find.text(label), findsOneComponent);
      }
      expect(find.text('Playground'), findsNothing);
      expect(find.text('pub.dev ↗'), findsNothing);
    });

    testComponents('HeroSection renders headline, command bar and CTAs', (tester) async {
      tester.pumpComponent(const HeroSection());

      expect(find.text('Big forms. Less code.'), findsOneComponent);
      expect(find.text('One rebuild per keystroke.'), findsOneComponent);
      for (final chip in ['MIT', 'Pure Dart core', 'Flutter']) {
        expect(find.text(chip), findsOneComponent);
      }
      expect(find.text('flutter pub add keyed_form_flutter keyed_form_schema'), findsOneComponent);
      expect(find.text('COPY'), findsOneComponent);
      expect(find.text('Build your first form →'), findsOneComponent);
      expect(find.text('Open full playground →'), findsOneComponent);
    });

    // Typing is exercised in a real browser (see the redesign's CDP checks):
    // jaspr_test can't synthesise an input event carrying a value.
    testComponents('HeroLoginDemo starts with both rebuild counters at zero', (tester) async {
      tester.pumpComponent(const HeroLoginDemo());

      expect(find.text('Email'), findsOneComponent);
      expect(find.text('Password'), findsOneComponent);
      expect(find.text('rebuilds: 0'), findsNComponents(2));
      expect(find.text('Sign in'), findsOneComponent);
    });
  });

  group('Code highlighting', () {
    test('tokens are classed by their innermost TextMate scope', () {
      expect(tokenClassFor(['storage.modifier.dart']), 'tk-keyword');
      expect(tokenClassFor(['meta.declaration.dart', 'keyword.other.import.dart']), 'tk-keyword');
      expect(tokenClassFor(['string.interpolated.single.dart']), 'tk-string');
      expect(tokenClassFor(['comment.line.double-slash.dart']), 'tk-comment');
      expect(tokenClassFor(['support.class.dart']), 'tk-type');
      expect(tokenClassFor(['storage.type.annotation.dart']), 'tk-annotation');
      expect(tokenClassFor(['keyword.operator.assignment.dart']), isNull);
      expect(tokenClassFor([]), isNull);
    });

    test('highlightDart splits code into tokens', () {
      expect(highlightDart("final name = 'Ann';").length, greaterThan(3));
    });

    testComponents('CodeTabs renders one radio + label + panel per tab, first checked', (tester) async {
      tester.pumpComponent(
        const CodeTabs(
          id: 'demo',
          tabs: [CodeTab('a.dart', 'class A {}'), CodeTab('b.dart', 'class B {}')],
        ),
      );

      expect(find.text('a.dart'), findsOneComponent);
      expect(find.text('b.dart'), findsOneComponent);
      expect(find.tag('input'), findsNComponents(2));
      expect(find.text('COPY'), findsNComponents(2));
    });
  });

  group('Example sources', () {
    // Formatting differs (website: 120 columns, example: 80), so compare
    // without whitespace.
    String rules(String source) => source.substring(source.indexOf('final _')).replaceAll(RegExp(r'\s'), '');

    for (final (web, example) in [
      ('lib/demos/login_schema.dart', ExampleFiles.loginSchema),
      ('lib/demos/packing_schema.dart', ExampleFiles.packingSchema),
    ]) {
      test('$web matches the Flutter example schema', () {
        expect(
          rules(File(web).readAsStringSync()),
          rules(File('$exampleLibDir/$example').readAsStringSync()),
        );
      });
    }
  });

  test('search index contains all reorganized pages and their track labels', () {
    final entries = readDocsSearchIndex();
    expect(entries.where((e) => e['section']!.isEmpty).length, 38);
    expect(entries.every((entry) => entry['docSection'] != 'docs'), isTrue);
    expect(entries.any((entry) => entry['url']!.endsWith('/docs/validation')), isFalse);

    final strings = entries.firstWhere((entry) => entry['url']!.endsWith('/docs/schema/builders#strings'));
    expect(strings['docSection'], 'schema');
    expect(strings['docSectionTitle'], 'Schema');
    expect(strings['text'], contains('ks.string'));
    expect(strings['text'], contains('regex'));
    expect(entries.any((entry) => entry['docSectionTitle'] == 'Form State'), isTrue);
  });

  test('docs registry covers every Markdown file by unique nested content path', () {
    final files = Directory('content/docs')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path.replaceFirst('content/', ''))
        .where((path) => path.endsWith('.md'))
        .toSet();
    final paths = docsPages.map((page) => page.contentPath).toList();
    expect(paths, hasLength(61));
    expect(paths.toSet(), hasLength(paths.length));
    expect(paths.toSet(), files);
    for (final section in docsSections) {
      expect(docsPagesFor(section).where((page) => page.slug == 'index'), hasLength(1));
    }
  });

  group('Static Site Output Verification', () {
    test('all section roots and nested docs outputs are generated', () {
      for (final route in [
        'docs/guides/index.html',
        'docs/schema/index.html',
        'docs/form-state/index.html',
        'docs/flutter/index.html',
        'docs/schema/code-generation/index.html',
        'docs/schema/code-generation/index.html.md',
        'docs/index.html',
        'docs/quickstart/index.html',
        'playground/index.html',
      ]) {
        expect(File('build/jaspr/$route').existsSync(), isTrue, reason: route);
      }
    });

    test('section sidebars, active tabs, and pager stay within their track', () {
      final schema = File('build/jaspr/docs/schema/builders/index.html').readAsStringSync();
      final schemaNavStart = schema.indexOf('<nav class="md-sidebar-scroll"');
      final schemaSidebar = schema.substring(schemaNavStart, schema.indexOf('</nav>', schemaNavStart) + 6);
      expect(schema, contains('aria-current="location"'));
      expect(RegExp(r'class="docs-tab active"').allMatches(schema).length, 1);
      expect(schema, contains('class="docs-tab active" aria-current="location" href="${_siteRoute('/docs/schema')}"'));
      expect(schemaSidebar, contains('data-docs-section="schema"'));
      expect(schemaSidebar, contains(_siteRoute('/docs/schema/composition')));
      expect(schemaSidebar, isNot(contains(_siteRoute('/docs/guides/'))));
      expect(schemaSidebar, isNot(contains(_siteRoute('/docs/form-state/'))));
      expect(schema, contains('kf-sidebar-scroll:'));
      expect(schema, contains('class="copy-page"'));
      expect(schema, contains('class="md-anchor"'));
      expect(schema, contains('class="docs-footer"'));

      final schemaRoot = File('build/jaspr/docs/schema/index.html').readAsStringSync();
      expect(schemaRoot, isNot(contains('rel="prev"')));
      expect(schemaRoot, contains('href="${_siteRoute('/docs/schema/builders')}"'));
      final schemaLast = File('build/jaspr/docs/schema/code-generation/index.html').readAsStringSync();
      expect(schemaLast, isNot(contains('rel="next"')));
      final flutterLast = File('build/jaspr/docs/flutter/api-reference/index.html').readAsStringSync();
      expect(flutterLast, isNot(contains('rel="next"')));

      final comparison = File('build/jaspr/docs/validation/index.html').readAsStringSync();
      final comparisonNavStart = comparison.indexOf('<nav class="md-sidebar-scroll"');
      final comparisonSidebar = comparison.substring(
        comparisonNavStart,
        comparison.indexOf('</nav>', comparisonNavStart) + 6,
      );
      expect(comparison, contains('Comparison copy: this is the previous documentation'));
      expect(comparison, contains('href="${_siteRoute('/docs/guides')}"'));
      expect(comparisonSidebar, contains('data-docs-section="docs"'));
      expect(comparisonSidebar, contains(_siteRoute('/docs/async-validation')));
      expect(comparisonSidebar, isNot(contains(_siteRoute('/docs/schema/'))));

      final playground = File('build/jaspr/playground/index.html').readAsStringSync();
      final tabsStart = playground.indexOf('<nav class="docs-tabs"');
      final tabs = playground.substring(tabsStart, playground.indexOf('</nav>', tabsStart) + 6);
      expect(tabs, isNot(contains('class="docs-tab active"')));
      expect(tabs, isNot(contains('Playground')));
    });

    test('new and comparison Markdown copies remain separate', () {
      final generated = File('build/jaspr/docs/schema/builders/index.html.md').readAsStringSync();
      expect(generated, startsWith('# Builders and rules\n'));
      expect(File('build/jaspr/docs/validation/index.html.md').existsSync(), isTrue);
      expect(File('build/jaspr/docs/index.html.md').existsSync(), isTrue);
    });

    test('build/jaspr contains valid production static assets', () {
      final htmlFile = File('build/jaspr/index.html');
      expect(htmlFile.existsSync(), isTrue);

      final content = htmlFile.readAsStringSync();

      // Basic Document Structure
      expect(content, contains('<!DOCTYPE html>'));
      expect(content, contains('<html lang="en">'));
      expect(content, isNot(contains('<html lang="en" data-theme="dark">')));
      expect(
        content,
        contains(
          '<title>keyed_form — big Flutter forms, one rebuild per keystroke</title>',
        ),
      );
      expect(content, contains('<meta name="twitter:card" content="summary"/>'));
      expect(
        content,
        contains('<meta name="twitter:image" content="https://keyed-form.v4g.space/images/logo.png"/>'),
      );
      expect(
        content,
        contains('<meta property="og:image" content="https://keyed-form.v4g.space/images/logo.png"/>'),
      );
      expect(File('build/jaspr/images/logo.png').existsSync(), isTrue);

      // System Theme & Preference restore script
      expect(content, contains('localStorage.getItem(\'theme\')'));
      expect(content, contains('@media all and (prefers-color-scheme: light)'));
      expect(content, contains('@media all and (prefers-color-scheme: dark)'));
      expect(content, contains(':root:not([data-theme="dark"])'));
      expect(content, contains(':root:not([data-theme="light"])'));

      // Critical sections present
      expect(content, contains('id="features"'));
      expect(content, contains('id="benchmarks"'));
      expect(content, contains('id="model"'));

      // Client hydration script present
      expect(content, contains('src="main.client.dart.js"'));

      // CSS Custom Properties and Blueprint Grid verification
      expect(content, contains(':root[data-theme="dark"]'));
      expect(content, contains(':root[data-theme="light"]'));
      expect(content, contains('--cyan: #00f0ff'));
      expect(content, contains('--cyan: #008799'));
      expect(content, contains('--grid: rgba(0, 240, 255, 0.04)'));
      expect(
        content,
        contains('linear-gradient(to right, var(--grid) 1px, transparent 1px)'),
      );

      // Check client JS file exists
      final jsFile = File('build/jaspr/main.client.dart.js');
      expect(jsFile.existsSync(), isTrue);
      expect(jsFile.lengthSync(), greaterThan(10000));
    });
  });
}
