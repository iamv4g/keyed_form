import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

@client
class CodeSection extends StatefulComponent {
  const CodeSection({super.key});

  @override
  State<CodeSection> createState() => _CodeSectionState();
}

class _CodeSectionState extends State<CodeSection> {
  int _activeTab = 0;
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static const _codeSnippets = [
    '''// tour_schema.dart — Declare schema once with declarative rules
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'tour_schema.kfg.dart';

final _tourSchema = ks.object({
  'title': ks.string().min(3),
  'stops': ks.list(
    ks.object(className: 'StopSchema', {
      'city': ks.string(),
      'nights': ks.int().min(1).defaultTo(1),
    }),
  ),
});''',
    '''// tour_view.dart — Clean Flutter binding without forced Material styles
import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

KeyedForm<TourSchema>(
  controller: formController,
  child: Column(
    children: [
      // Single field with automatic controller disposal
      KeyedFormField(
        field: TourFields.title,
        builder: (context, state, binding) {
          return TextField(
            controller: binding.controller,
            decoration: InputDecoration(
              labelText: 'Tour Title',
              errorText: state.error?.message,
            ),
          );
        },
      ),
      // Reorder-safe dynamic list
      KeyedFieldList(
        field: TourFields.stops,
        builder: (context, items, listController) {
          return ReorderableListView.builder(
            itemCount: items.length,
            onReorder: listController.reorder,
            itemBuilder: (context, index) => StopRow(key: items[index].key),
          );
        },
      ),
    ],
  ),
)''',
    '''// tour_schema.kfg.dart (Generated via build_runner)
part of 'tour_schema.dart';

abstract final class TourFields {
  static StrictFieldRef<TourSchema, String> get title => ...;
  static StopFieldRefs stop({required String stopClientId}) => ...;
}

// Anywhere in your application:
form.field(TourFields.stop(stopClientId: itemKey).nights).set(4);   // 100% Typo-Proof''',
  ];

  void _copy() {
    if (kIsWeb) {
      web.window.navigator.clipboard.writeText(_codeSnippets[_activeTab]);
      setState(() {
        _copied = true;
      });
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _copied = false;
          });
        }
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return section(id: 'code', classes: 'wrap', [
      span(classes: 'section-kicker mono', [
        .text('// IMPLEMENTATION PATTERN'),
      ]),
      h2(classes: 'section-title display', [
        .text('From declarative schema to Flutter widget'),
      ]),
      p(classes: 'section-lede', [
        .text(
          'One declarative schema file produces immutable data models, typed optics lenses, and validation rules. Then bind to standard Flutter widgets without opinionated framework styling.',
        ),
      ]),
      div(classes: 'blueprint-box code-container', [
        div(classes: 'code-header-bar mono', [
          div(classes: 'code-tabs', [
            button(
              classes: 'tab-btn${_activeTab == 0 ? ' active' : ''}',
              onClick: () => setState(() => _activeTab = 0),
              [.text('1. Schema DSL (tour_schema.dart)')],
            ),
            button(
              classes: 'tab-btn${_activeTab == 1 ? ' active' : ''}',
              onClick: () => setState(() => _activeTab = 1),
              [.text('2. Flutter UI Binding (tour_view.dart)')],
            ),
            button(
              classes: 'tab-btn${_activeTab == 2 ? ' active' : ''}',
              onClick: () => setState(() => _activeTab = 2),
              [.text('3. Generated Optics (tour_schema.kfg.dart)')],
            ),
          ]),
          button(
            classes: 'copy-btn mono',
            onClick: _copy,
            [.text(_copied ? 'COPIED!' : 'COPY SNIPPET')],
          ),
        ]),
        if (_activeTab == 0)
          div(id: 'code-tab-0', classes: 'code-content mono', [
            pre([
              span(classes: 'syntax-comment', [
                .text(
                  '// tour_schema.dart — Declare schema once with declarative rules\n',
                ),
              ]),
              span(classes: 'syntax-keyword', [.text('@keyedSchema\n')]),
              span(classes: 'syntax-keyword', [.text('library')]),
              .text(';\n\n'),
              span(classes: 'syntax-keyword', [.text('import')]),
              .text(' '),
              span(classes: 'syntax-string', [
                .text("'package:keyed_form_schema/keyed_form_schema.dart'"),
              ]),
              .text(';\n\n'),
              span(classes: 'syntax-keyword', [.text('part')]),
              .text(' '),
              span(classes: 'syntax-string', [.text("'tour_schema.kfg.dart'")]),
              .text(';\n\n'),
              span(classes: 'syntax-keyword', [.text('final')]),
              .text(' _tourSchema = ks.object({\n  '),
              span(classes: 'syntax-string', [.text("'title'")]),
              .text(': ks.string().min(3),\n  '),
              span(classes: 'syntax-string', [.text("'stops'")]),
              .text(": ks.list(\n    ks.object(className: "),
              span(classes: 'syntax-string', [.text("'StopSchema'")]),
              .text(', {\n      '),
              span(classes: 'syntax-string', [.text("'city'")]),
              .text(': ks.string(),\n      '),
              span(classes: 'syntax-string', [.text("'nights'")]),
              .text(': ks.int().min(1).defaultTo(1),\n    }),\n  ),\n});'),
            ]),
          ]),
        if (_activeTab == 1)
          div(id: 'code-tab-1', classes: 'code-content mono', [
            pre([
              span(classes: 'syntax-comment', [
                .text(
                  '// tour_view.dart — Clean Flutter binding without forced Material styles\n',
                ),
              ]),
              span(classes: 'syntax-keyword', [.text('import')]),
              .text(' '),
              span(classes: 'syntax-string', [
                .text("'package:flutter/material.dart'"),
              ]),
              .text(';\n'),
              span(classes: 'syntax-keyword', [.text('import')]),
              .text(' '),
              span(classes: 'syntax-string', [
                .text(
                  "'package:keyed_form_flutter/keyed_form_flutter.dart'",
                ),
              ]),
              .text(';\n\n'),
              .text('KeyedForm<TourSchema>(\n'),
              .text('  controller: formController,\n'),
              .text('  child: Column(\n'),
              .text('    children: [\n'),
              span(classes: 'syntax-comment', [
                .text(
                  '      // Single field with automatic controller disposal\n',
                ),
              ]),
              .text('      KeyedFormField(\n'),
              .text('        field: TourFields.title,\n'),
              .text('        builder: (context, state, binding) {\n'),
              .text('          '),
              span(classes: 'syntax-keyword', [.text('return')]),
              .text(' TextField(\n'),
              .text('            controller: binding.controller,\n'),
              .text('            decoration: InputDecoration(\n'),
              .text('              labelText: '),
              span(classes: 'syntax-string', [.text("'Tour Title'")]),
              .text(',\n'),
              .text('              errorText: state.error?.message,\n'),
              .text('            ),\n'),
              .text('          );\n'),
              .text('        },\n'),
              .text('      ),\n'),
              span(classes: 'syntax-comment', [
                .text('      // Reorder-safe dynamic list\n'),
              ]),
              .text('      KeyedFieldList(\n'),
              .text('        field: TourFields.stops,\n'),
              .text('        builder: (context, items, listController) {\n'),
              .text('          '),
              span(classes: 'syntax-keyword', [.text('return')]),
              .text(' ReorderableListView.builder(\n'),
              .text('            itemCount: items.length,\n'),
              .text('            onReorder: listController.reorder,\n'),
              .text(
                '            itemBuilder: (context, index) => StopRow(key: items[index].key),\n',
              ),
              .text('          );\n'),
              .text('        },\n'),
              .text('      ),\n'),
              .text('    ],\n'),
              .text('  ),\n'),
              .text(')'),
            ]),
          ]),
        if (_activeTab == 2)
          div(id: 'code-tab-2', classes: 'code-content mono', [
            pre([
              span(classes: 'syntax-comment', [
                .text('// tour_schema.kfg.dart (Generated via build_runner)\n'),
              ]),
              span(classes: 'syntax-keyword', [.text('part of')]),
              .text(' '),
              span(classes: 'syntax-string', [.text("'tour_schema.dart'")]),
              .text(';\n\n'),
              span(classes: 'syntax-keyword', [
                .text('abstract final class'),
              ]),
              .text(' TourFields {\n'),
              .text('  '),
              span(classes: 'syntax-keyword', [.text('static')]),
              .text(' StrictFieldRef<TourSchema, String> '),
              span(classes: 'syntax-keyword', [.text('get')]),
              .text(' title => ...;\n'),
              .text('  '),
              span(classes: 'syntax-keyword', [.text('static')]),
              .text(
                ' StopFieldRefs stop({required String stopClientId}) => ...;\n',
              ),
              .text('}\n\n'),
              span(classes: 'syntax-comment', [
                .text('// Anywhere in your application:\n'),
              ]),
              .text(
                'form.field(TourFields.stop(stopClientId: itemKey).nights).set(4);   ',
              ),
              span(classes: 'syntax-success', [.text('// 100% Typo-Proof')]),
            ]),
          ]),
      ]),
    ]);
  }
}
