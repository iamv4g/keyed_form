import 'dart:io';

import 'package:jaspr_test/jaspr_test.dart';
import 'package:website/code/code_tabs.dart';
import 'package:website/code/highlight.dart';
import 'package:website/components/agent_skill_section.dart';
import 'package:website/components/demo/hero_login_demo.dart';
import 'package:website/components/hero_section.dart';
import 'package:website/components/lists_section.dart';
import 'package:website/components/model_section.dart';
import 'package:website/components/telemetry_section.dart';
import 'package:website/components/navbar.dart';
import 'package:website/pages/docs_page.dart';
import 'package:website/pages/landing_page.dart';

void main() {
  setUpAll(initHighlighter);

  group('Website Component Tests', () {
    testComponents('renders full App with all landing page sections', (
      tester,
    ) async {
      tester.pumpComponent(const LandingPage());

      // Brand & Navigation
      expect(find.textContaining('keyed_form'), findsComponents);
      expect(find.text('Docs'), findsOneComponent);
      expect(find.text('Playground'), findsOneComponent);

      // Section Kickers
      expect(find.text('// ARCHITECTURAL INVARIANTS'), findsOneComponent);
      expect(find.text('// MEASURED'), findsOneComponent);
      expect(find.text('// CAPABILITY MATRIX'), findsOneComponent);
      expect(find.text('// THE MODEL'), findsOneComponent);
      expect(find.text('// AGENT SKILL'), findsOneComponent);
      expect(find.text('// DYNAMIC LISTS'), findsOneComponent);
      expect(find.text('// WORKSPACE TOPOLOGY'), findsOneComponent);

      // Footer
      expect(
        find.text(
          ' — Typed forms on keyed optics. Released under the MIT License.',
        ),
        findsOneComponent,
      );
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

    testComponents('DocsPage renders 6 developer chapters and reassurance callout', (
      tester,
    ) async {
      tester.pumpComponent(const DocsPage());

      // Navigation & Branding — shares the same Navbar as every other page
      expect(find.text(' keyed_form'), findsOneComponent);
      expect(find.text('Docs'), findsOneComponent);

      // Section titles
      expect(find.text('Overview & The Problem with Traditional Forms'), findsOneComponent);
      expect(find.text('Thinking in Keyed Optics'), findsComponents);
      expect(find.text('Quickstart in 5 Minutes'), findsOneComponent);
      expect(find.text('Form Controller & State Lifecycle'), findsOneComponent);
      expect(find.text('Lazy Scroll, Virtualization & State Preservation'), findsOneComponent);
      expect(find.text('Real-World Production Recipes'), findsOneComponent);
      expect(find.text('Testing Without Widgets: Pure Dart in < 2ms'), findsOneComponent);
      expect(find.text('API Reference'), findsComponents);

      // Reassurance Callout
      expect(find.textContaining("Don't Worry About Optics / Lenses!"), findsOneComponent);
    });

    testComponents('ModelSection shows the three login files, the demo and the points', (tester) async {
      tester.pumpComponent(const ModelSection());

      expect(find.text('// THE MODEL'), findsOneComponent);
      for (final file in ['login_schema.dart', 'login_form.dart', 'login_text_field.dart']) {
        expect(find.text(file), findsOneComponent);
      }
      expect(find.text('Full example'), findsOneComponent);
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
      tester.pumpComponent(const ListsSection());

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

  group('Static Site Output Verification', () {
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

      // System Theme & Preference restore script
      expect(content, contains('localStorage.getItem(\'theme\')'));
      expect(content, contains('@media all and (prefers-color-scheme: light)'));
      expect(content, contains('@media all and (prefers-color-scheme: dark)'));
      expect(content, contains(':root:not([data-theme="dark"])'));
      expect(content, contains(':root:not([data-theme="light"])'));

      // Critical sections present
      expect(content, contains('id="problems"'));
      expect(content, contains('id="benchmarks"'));
      expect(content, contains('id="matrix"'));
      expect(content, contains('id="model"'));
      expect(content, contains('id="packages"'));

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

      // Mobile Responsive & Overflow Containment verification
      expect(content, contains('@media screen and (max-width: 768px)'));
      expect(content, contains('overflow-x: clip'));
      expect(content, contains('flex: 1'));
      expect(content, contains('min-width: 0'));
      expect(content, contains('border-collapse: collapse'));
    });
  });
}
