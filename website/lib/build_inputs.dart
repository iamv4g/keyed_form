import 'dart:io';

import 'base_path.dart';
import 'docs_content/docs_nav.dart';
import 'docs_content/search_index.dart';
import 'example_sources.dart';

// Server/test only (dart:io). Paths are relative to `website/`, where builds
// and tests run.

/// `name → version` from `../packages/*/pubspec.yaml`.
Map<String, String> readPackageVersions() {
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

/// [ExampleFiles] read from the Flutter example; a missing file throws.
Map<String, String> readExampleSources() => {
  for (final path in ExampleFiles.all) path: File('$exampleLibDir/$path').readAsStringSync().trimRight(),
};

const exampleLibDir = '../packages/keyed_form_flutter/example/lib';

/// One entry per page intro and per `##`/`###` section of every docs page,
/// in sidebar order. Markdown is reduced to plain text; custom tags drop out.
List<SearchEntry> readDocsSearchIndex() {
  final entries = <SearchEntry>[];
  for (final page in docsPages) {
    final file = File('content/docs/${page.slug}.md');
    if (!file.existsSync()) continue;
    var body = file.readAsStringSync();
    var description = '';
    final frontmatter = RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(body);
    if (frontmatter != null) {
      description = RegExp(r'^description:\s*(.*)$', multiLine: true).firstMatch(frontmatter.group(1)!)?.group(1) ?? '';
      body = body.substring(frontmatter.end);
    }
    final url = '$siteBasePath${page.path}';
    var section = '';
    var anchor = '';
    final text = StringBuffer('$description\n');
    void flush() {
      entries.add({
        'title': page.title,
        'section': section,
        'url': anchor.isEmpty ? url : '$url#$anchor',
        'text': _plain(text.toString()),
      });
      text.clear();
    }

    var inFence = false;
    for (final line in body.split('\n')) {
      if (line.startsWith('```')) {
        inFence = !inFence;
        continue;
      }
      final heading = inFence ? null : RegExp(r'^#{2,3}\s+(.*)$').firstMatch(line);
      if (heading != null) {
        flush();
        section = heading.group(1)!.trim();
        anchor = headingId(section);
      } else if (!inFence) {
        text.writeln(line);
      }
    }
    flush();
  }
  return entries;
}

/// The id the Markdown renderer gives a heading.
String headingId(String text) => text.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9 _-]'), '').replaceAll(' ', '-');

String _plain(String markdown) {
  final text = markdown
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!)
      .replaceAll(RegExp(r'^[\s|:-]+$', multiLine: true), '')
      .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'\*\*|[`|>#]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return text.length > 280 ? '${text.substring(0, 277)}…' : text;
}
