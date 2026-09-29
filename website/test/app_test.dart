import 'dart:io';

import 'package:jaspr_test/jaspr_test.dart';
import 'package:website/components/code_section.dart';
import 'package:website/components/demo/hero_login_demo.dart';
import 'package:website/components/hero_section.dart';
import 'package:website/components/navbar.dart';
import 'package:website/pages/docs_page.dart';
import 'package:website/pages/landing_page.dart';

void main() {
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
      expect(find.text('// MEASURED TELEMETRY'), findsOneComponent);
      expect(find.text('// CAPABILITY MATRIX'), findsOneComponent);
      expect(find.text('// IMPLEMENTATION PATTERN'), findsOneComponent);
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

    testComponents('CodeSection switches tabs on click', (tester) async {
      tester.pumpComponent(const CodeSection());

      // Initial tab is Schema DSL
      expect(
        find.text('1. Schema DSL (tour_schema.dart)'),
        findsOneComponent,
      );
      expect(find.text('COPY SNIPPET'), findsOneComponent);
      expect(find.text('@keyedSchema\n'), findsOneComponent);

      // Switch to tab 2: Flutter UI Binding
      final tab2Button = find.ancestor(
        of: find.textContaining('2. Flutter UI Binding'),
        matching: find.tag('button'),
      );
      await tester.click(tab2Button);

      expect(
        find.text('1. Schema DSL (tour_schema.dart)'),
        findsOneComponent,
      );
      expect(find.text('@keyedSchema\n'), findsNothing);
      expect(find.textContaining('KeyedForm<TourSchema>'), findsOneComponent);

      // Switch to tab 3: Generated Optics
      final tab3Button = find.ancestor(
        of: find.textContaining('3. Generated Optics'),
        matching: find.tag('button'),
      );
      await tester.click(tab3Button);

      expect(find.textContaining('abstract final class'), findsOneComponent);
      expect(find.text('// 100% Typo-Proof'), findsOneComponent);
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
      expect(content, contains('id="code"'));
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
