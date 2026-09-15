import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class InvariantsGrid extends StatelessComponent {
  const InvariantsGrid({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'problems', classes: 'wrap', [
      span(classes: 'section-kicker mono', [
        .text('// ARCHITECTURAL INVARIANTS'),
      ]),
      h2(classes: 'section-title display', [
        .text(
          'One schema replaces the boilerplate — and what usually breaks around it',
        ),
      ]),
      p(classes: 'section-lede', [
        .text(
          'Three critical problems Flutter forms face at enterprise scale. Handled or generated at the compiler level.',
        ),
      ]),
      div(classes: 'blueprint-grid', [
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [
              .text('01 / NESTED IMMUTABLE UPDATES'),
            ]),
            div(classes: 'card-h', [.text('No manual copyWith chains')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' Updating one deeply nested field means hand-threading copyWith through every parent — tour.copyWith(stops: [...tour.stops.map((s) => s.clientId == id ? s.copyWith(nights: v) : s)]).',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' form.field(ref).set(v) — the nested copyWith chain is embedded in the generated FieldRef itself, never hand-written.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [
              .text('02 / DYNAMIC LIST REORDERING'),
            ]),
            div(classes: 'card-h', [
              .text('Stable identity across reorders'),
            ]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' Rows tracked by list array index — reordering shifts text controller contents into incorrect rows during animations.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' Rows are addressed by immutable FieldKey (UUID), never index. Controllers stay pinned through append, remove, or drag-to-reorder.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [.text('03 / TYPE SAFETY')]),
            div(classes: 'card-h', [.text('Zero runtime string typos')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                " Form controls looked up by string names ('email', 'age') — property renames compile fine but crash at runtime.",
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' Generated FieldRef<Root, V> coordinates — mistyped field names or mismatched types refuse to compile.',
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
