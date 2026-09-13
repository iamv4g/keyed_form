import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'copy_button.dart';

class TopologySection extends StatelessComponent {
  const TopologySection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'packages', classes: 'wrap', [
      span(classes: 'section-kicker mono', [
        .text('// WORKSPACE TOPOLOGY'),
      ]),
      h2(classes: 'section-title display', [
        .text('Six packages, one clean dependency chain'),
      ]),
      p(classes: 'section-lede', [
        .text(
          'A native Dart pub workspace. The entire core is pure Dart with zero Flutter dependencies until the final widget layer — form logic is 100% unit-testable in CI without pumping widgets.',
        ),
      ]),
      div(classes: 'topology-grid mono', [
        div(classes: 'blueprint-box topology-card', [
          div(classes: 'topology-title', [.text('keyed_lens')]),
          div(classes: 'topology-desc', [
            .text(
              'Pure Dart (0 deps). General-purpose composable keyed optics (Lens, AffineLens, Prism, FieldKey).',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box topology-card', [
          div(classes: 'topology-title', [.text('keyed_form_core')]),
          div(classes: 'topology-desc', [
            .text(
              'Depends on keyed_lens. Shared vocabulary: FieldRef, StrictFieldRef, FieldErrors, @keyedSchema.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box topology-card', [
          div(classes: 'topology-title', [.text('keyed_form_schema')]),
          div(classes: 'topology-desc', [
            .text(
              'Depends on keyed_form_core. Declarative schema & validation DSL (ks.*). Pure Dart.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box topology-card', [
          div(classes: 'topology-title', [.text('keyed_form_gen')]),
          div(classes: 'topology-desc', [
            .text(
              'Dev-time build_runner codegen: transforms schemas into immutable models, typed refs & validators.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box topology-card', [
          div(classes: 'topology-title', [.text('keyed_form')]),
          div(classes: 'topology-desc', [
            .text(
              'Pure-Dart state controller (KeyedFormController) with scoped reactive listener bindings.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box topology-card flutter-layer', [
          div(classes: 'topology-title text-cyan', [
            .text('keyed_form_flutter'),
          ]),
          div(classes: 'topology-desc', [
            .text(
              'The Flutter binding layer: KeyedForm, KeyedFormField, KeyedFieldList, KeyedTextBinding.',
            ),
          ]),
        ]),
      ]),
      div(classes: 'blueprint-box code-container mt-24', [
        div(classes: 'code-header-bar mono', [
          span(classes: 'code-filename mono', [.text('pubspec.yaml')]),
          const CopyButton(
            text:
                'dependencies:\n  keyed_form_flutter: ^0.1.0\n  keyed_form_schema: ^0.1.0\n\ndev_dependencies:\n  build_runner: ^2.15.0\n  keyed_form_gen: ^0.1.0',
            label: 'COPY DEPS',
          ),
        ]),
        div(classes: 'code-content mono', [
          pre([
            span(classes: 'syntax-comment', [.text('dependencies:\n')]),
            .text('  keyed_form_flutter: ^0.1.0\n  keyed_form_schema: ^0.1.0\n\n'),
            span(classes: 'syntax-comment', [.text('dev_dependencies:\n')]),
            .text('  build_runner: ^2.15.0\n  keyed_form_gen: ^0.1.0'),
          ]),
        ]),
      ]),
    ]);
  }
}
