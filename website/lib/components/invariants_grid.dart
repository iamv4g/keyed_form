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
          'Nine critical problems Flutter forms face at enterprise scale. Handled or generated at the compiler level.',
        ),
      ]),
      div(classes: 'blueprint-grid', [
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [.text('01 / BOILERPLATE IN SYNC')]),
            div(classes: 'card-h', [.text('Schema in, typed everything out')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' Hand-written model classes, separate validate() functions, and GlobalKey<FormState> wiring — three places to update for every single field addition.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' Single declarative schema. build_runner automatically generates immutable models, typed field references, and validation rules.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [.text('02 / CONTROLLER LEAKAGE')]),
            div(classes: 'card-h', [
              .text('Zero TextEditingController tracking'),
            ]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' Creating 20+ TextEditingControllers in initState() and disposing each in dispose(). One forgotten dispose() triggers a silent memory leak.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' KeyedTextBinding automatically owns and disposes controllers scoped to the widget lifecycle.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [
              .text('03 / DYNAMIC LIST REORDERING'),
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
            div(classes: 'card-num mono', [
              .text('04 / OFF-SCREEN UNMOUNTING'),
            ]),
            div(classes: 'card-h', [
              .text('State persists outside widget tree'),
            ]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' ListView and PageView dispose off-screen widget state by default — user inputs reset unless wrapped with AutomaticKeepAliveClientMixin.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' State resides in pure Dart outside the tree; re-mounted fields instantly read their slice back.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [
              .text('05 / REBUILD COMPLEXITY'),
            ]),
            div(classes: 'card-h', [.text('Strict O(1) Rebuild Isolation')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' Single ChangeNotifier triggers cascading subtree rebuilds on every keystroke, dropping frame rates in complex forms.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' Every read is isolated to a FieldKey — only the exact widget that changed rebuilds.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [.text('06 / TYPE SAFETY')]),
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
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [.text('07 / ASYNC VALIDATION')]),
            div(classes: 'card-h', [.text('Distinct check-failed states')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' "Invalid input" and "network check failed" collapse into one state — leaving infinite spinners after a dropped network request.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' isValidating and isFailedValidation are distinct, timeout-aware states immune to stale clobbering.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [
              .text('08 / WIRE PROTOCOL CODEC'),
            ]),
            div(classes: 'card-h', [.text('Direct server error mapping')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' HTTP 422 JSON validation bodies need tedious, bespoke glue code to map error strings back onto nested widgets.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' FieldKey features a frozen wire codec (toPath() / parse()) — setServerErrorPaths maps JSON bodies directly onto fields.',
            ),
          ]),
        ]),
        div(classes: 'blueprint-box grid-card', [
          div([
            div(classes: 'card-num mono', [
              .text('09 / ZERO OPINIONATED STYLING'),
            ]),
            div(classes: 'card-h', [.text('Bring your own design system')]),
            div(classes: 'card-p', [
              strong([.text('The usual way:')]),
              .text(
                ' Adopting a form library forces its Material-styled widgets — reskinning breaks upon Flutter major upgrades.',
              ),
            ]),
          ]),
          div(classes: 'card-diff mono', [
            strong([.text('keyed_form:')]),
            .text(
              ' KeyedForm ships no styled UI: builder: (context, state, binding) hands you state to render with your own design system.',
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
