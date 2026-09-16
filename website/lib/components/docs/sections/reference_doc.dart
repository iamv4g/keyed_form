import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_callout.dart';

class ReferenceDoc extends StatelessComponent {
  const ReferenceDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      // ---------------------------------------------------------------------
      // 6.1 API Reference
      // ---------------------------------------------------------------------
      div(id: 'api-reference', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 06.1 · API REFERENCE')]),
      h2(classes: 'docs-h2 display', [.text('API Reference')]),
      p([
        .text(
          "A lookup table of the core classes, methods, and properties across keyed_form's ecosystem:",
        ),
      ]),

      h3(classes: 'docs-h3 display', [.text('1. KeyedFormController<Root>')]),
      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          thead([
            tr([
              th([.text('Member')]),
              th([.text('Type / Signature')]),
              th([.text('Description')]),
            ]),
          ]),
          tbody([
            tr([
              td(classes: 'feat mono', [.text('value')]),
              td([.text('Root')]),
              td([.text("The form's current immutable draft.")]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('original')]),
              td([.text('Root')]),
              td([.text('The clean baseline diffed against for dirty checks.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('isDirty')]),
              td([.text('bool')]),
              td([.text('True if any field differs from the original baseline.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('differs(field)')]),
              td([.text('bool Function(FieldRef)')]),
              td([.text('Checks whether one specific field differs from the baseline.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('dirtyRows(listField)')]),
              td([.text('Iterable<FieldKey>')]),
              td([.text("Row keys of the list's rows that changed from the baseline.")]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('field(ref)')]),
              td([.text('FieldHandle<Root, V>')]),
              td([.text('Gets a fully typed handle for one specific field.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('seed(value, {force})')]),
              td([.text('void')]),
              td([.text('Sets a new clean baseline (use after fetching data from an API).')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('reset()')]),
              td([.text('void')]),
              td([.text('Restores the whole form to its seeded value and clears bookkeeping.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('submit(onValid, {onInvalid})')]),
              td([.text('Future<bool>')]),
              td([.text('Runs full validation, manages submitting state, calls back.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('handleSubmit(context, onValid)')]),
              td([.text('Future<bool>')]),
              td([.text("submit's Flutter-aware wrapper, auto-scrolling to the first error.")]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('setServerErrorPaths(...)')]),
              td([.text('void')]),
              td([.text("Maps a backend JSON error body (e.g. \"stops.['<clientId>'].city\") onto the matching FieldKey.")]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('addRelation(source, select, onChange)')]),
              td([.text('VoidCallback')]),
              td([.text('Registers a derived side-effect that fires when source changes.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('markReadOnly(key)')]),
              td([.text('void')]),
              td([.text('Freezes a field, or an entire subtree, against writes.')]),
            ]),
          ]),
        ]),
      ]),

      h3(classes: 'docs-h3 display mt-24', [.text('2. FieldHandle<Root, V>')]),
      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          thead([
            tr([
              th([.text('Member')]),
              th([.text('Type')]),
              th([.text('Description')]),
            ]),
          ]),
          tbody([
            tr([
              td(classes: 'feat mono', [.text('value')]),
              td([.text('V?')]),
              td([.text("The field's current typed value.")]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('set(newValue, {force})')]),
              td([.text('void')]),
              td([.text('Writes a new value; rebuilds only the observing widget (O(1)).')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('update(transform, {force})')]),
              td([.text('void')]),
              td([.text('Transforms the value atomically through a pure function.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('touch()')]),
              td([.text('void')]),
              td([.text('Marks the field touched — gates error visibility under the onBlur/onTouched modes (onChange touches automatically on write; onSubmit/all ignore touched state).')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('error')]),
              td([.text('String?')]),
              td([.text('The visible error, if the field is touched or a submit has failed.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('dirty')]),
              td([.text('bool')]),
              td([.text('True if the current value differs from the seeded baseline.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('isReadOnly')]),
              td([.text('bool')]),
              td([.text('True if the field is currently frozen against writes.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('isValidating')]),
              td([.text('bool')]),
              td([.text('True while the field is mid async validation.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('validateAsync(check, {timeout})')]),
              td([.text('Future<void>')]),
              td([.text('Runs an async check (e.g. a duplicate-email API call).')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('list()')]),
              td([.text('KeyedFormList<Root, Item>')]),
              td([.text('The by-clientId list editor, when the field is a List<Item>.')]),
            ]),
          ]),
        ]),
      ]),

      h3(classes: 'docs-h3 display mt-24', [.text('3. Flutter Bindings & Widgets')]),
      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          thead([
            tr([
              th([.text('Widget / Function')]),
              th([.text('Package')]),
              th([.text('Description')]),
            ]),
          ]),
          tbody([
            tr([
              td(classes: 'feat mono', [.text('KeyedFormField<Root, V>')]),
              td([.text('keyed_form_flutter')]),
              td([.text('Binds a widget to field state: value, onChanged, onBlur, errorText.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('KeyedFormField.text<Root>')]),
              td([.text('keyed_form_flutter')]),
              td([.text('Auto-manages a caret-stable TextEditingController via KeyedTextBinding.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('KeyedFieldList<Root, Item>')]),
              td([.text('keyed_form_flutter')]),
              td([.text('Hands your builder a list handle (append, removeById, move) keyed by stable clientId.')]),
            ]),
            tr([
              td(classes: 'feat mono', [.text('KeyedForm<Root>')]),
              td([.text('keyed_form_flutter')]),
              td([.text('The StatefulWidget that publishes the controller and owns the KeyedFieldRegistry used for scroll-to-error.')]),
            ]),
          ]),
        ]),
      ]),

      // ---------------------------------------------------------------------
      // 6.2 Migration Guide
      // ---------------------------------------------------------------------
      div(id: 'migration-guide', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 06.2 · MIGRATION')]),
      h2(classes: 'docs-h2 display', [.text('Migration Guide from Traditional Forms')]),
      p([
        .text('A quick lookup mapping familiar concepts onto keyed_form:'),
      ]),

      div(classes: 'table-scroll', [
        table(classes: 'spec', [
          thead([
            tr([
              th([.text('Vanilla / FormBuilder')]),
              th([.text('keyed_form Equivalent')]),
              th([.text('What You Gain')]),
            ]),
          ]),
          tbody([
            tr([
              td(classes: 'feat', [.text('GlobalKey<FormState>')]),
              td(classes: 'mono', [.text('KeyedFormController<Root>')]),
              td([.text('No dependency on BuildContext or the widget tree. Pure-Dart tests in <2ms.')]),
            ]),
            tr([
              td(classes: 'feat', [.text('TextEditingController')]),
              td(classes: 'mono', [.text('KeyedFormField.text<Root>')]),
              td([.text('Automatic two-way sync, caret-stable, no cursor jumps or memory leaks.')]),
            ]),
            tr([
              td(classes: 'feat', [.text('FormBuilderField(name: "age")')]),
              td(classes: 'mono', [.text('KeyedFormField(field: UserFields.age)')]),
              td([.text('100% static type checking at compile time, eliminating string-typo bugs.')]),
            ]),
            tr([
              td(classes: 'feat', [.text('ListView.builder(index)')]),
              td(classes: 'mono', [.text('KeyedFieldList(item.clientId)')]),
              td([.text("A permanent KeyedRow clientId that never crosses state during lazy scroll.")]),
            ]),
            tr([
              td(classes: 'feat', [.text('form.save() / form.validate()')]),
              td(classes: 'mono', [.text('form.handleSubmit(context, onValid)')]),
              td([.text('Atomic validation, auto-scroll to the first error, submitting state managed for you.')]),
            ]),
          ]),
        ]),
      ]),

      // ---------------------------------------------------------------------
      // 6.3 FAQ & Gotchas
      // ---------------------------------------------------------------------
      div(id: 'faq', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 06.3 · TROUBLESHOOTING')]),
      h2(classes: 'docs-h2 display', [.text('Troubleshooting & Gotchas (FAQ)')]),

      const DocsCallout(
        type: CalloutType.warning,
        title: "Ran build_runner but no *.kfg.dart file was generated?",
        content: Component.fragment([
          p([
            .text(
              "The usual cause is a missing `part 'your_file.kfg.dart';` declaration at the top of the schema file (note the `.kfg.dart` suffix specific to keyed_form_gen), or a missing `@keyedSchema` annotation. Make sure both are present before running `dart run build_runner build -d`.",
            ),
          ]),
        ]),
      ),

      const DocsCallout(
        type: CalloutType.note,
        title: 'How do I reset the form to the data from an API instead of blank?',
        content: Component.fragment([
          p([
            .text(
              "Use `controller.seed(apiData)`. `seed()` stores this value as the clean baseline. When the user hits Cancel and you call `controller.reset()`, the form returns to that exact `apiData` value instead of going blank.",
            ),
          ]),
        ]),
      ),

      const DocsCallout(
        type: CalloutType.tip,
        title: 'How do I auto-scroll to the first invalid field on a failed submit?',
        content: Component.fragment([
          p([
            .text(
              'Just call `form.handleSubmit(context, (data) async { ... })` from keyed_form_flutter. The built-in `KeyedFieldRegistry` computes the position and calls `Scrollable.ensureVisible()` on the first field with a visible error, automatically.',
            ),
          ]),
        ]),
      ),
    ]);
  }
}
