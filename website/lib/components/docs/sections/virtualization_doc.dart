import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../docs_callout.dart';
import '../docs_code_block.dart';

class VirtualizationDoc extends StatelessComponent {
  const VirtualizationDoc({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'docs-section', [
      div(id: 'virtualization', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 03.1 · THE VIRTUALIZATION DILEMMA')]),
      h2(classes: 'docs-h2 display', [.text('Lazy Scroll, Virtualization & State Preservation')]),

      const DocsCallout(
        type: CalloutType.tip,
        title: "keyed_form's Killer Feature",
        content: Component.fragment([
          p([
            .text(
              'In most Flutter form libraries, putting input fields inside an unbounded scrolling list (`ListView.builder` or `CustomScrollView`) is ',
            ),
            b([.text('the #1 cause of lost data and cross-talk between rows.')]),
          ]),
          p([
            .text(
              'keyed_form is designed from the ground up to solve this completely: ',
            ),
            b([
              .text(
                "hundreds of form rows can scroll tens of thousands of pixels off-screen and their data, validation errors, and dirty state stay 100% intact.",
              ),
            ]),
          ]),
        ]),
      ),

      p([
        .text(
          "Here's how Flutter actually behaves: when an item in a `ListView.builder` scrolls out of the viewport, Flutter calls `dispose()` on that item's `State` to free memory. When the user scrolls back, Flutter builds a brand-new `State`.",
        ),
      ]),
      p([
        .text(
          "If you keep a `TextEditingController` inside that item's State, everything the user typed is wiped out. And if you instead keep an external array of controllers indexed by `[0], [1], [2]`, deleting row 1 or dragging row 2 above row 1 shuffles data and focus across the wrong rows — index crosstalk.",
        ),
      ]),

      // ---------------------------------------------------------------------
      // 3.2 RowId vs Fragile Index
      // ---------------------------------------------------------------------
      div(id: 'rowid-vs-index', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 03.2 · ARCHITECTURE IN-DEPTH')]),
      h2(classes: 'docs-h2 display', [.text('Stable clientId vs Fragile Array Index [i]')]),
      p([
        .text(
          'keyed_form solves this at the root by managing lists through `KeyedFieldList<Root, Item>`, where every row implements `KeyedRow` and carries a **permanently stable `clientId`**:',
        ),
      ]),

      ul(classes: 'docs-list', [
        li([
          b([.text('Array Index (the fatal flaw of ordinary forms)')]),
          .text(
            ': With 3 rows `[A, B, C]`, deleting A shifts B to index 0 and C to index 1. Every widget and validation listener still pointing at index 0 now silently picks up the old row A\'s controller and error!',
          ),
        ]),
        li([
          b([.text("KeyedRow.clientId (keyed_form's solution)")]),
          .text(
            ": Every row carries a unique `clientId` (e.g. a UUID). Whether you move it to the top, the bottom, or delete rows around it, its coordinate is always `TourFields.stop((stop: stop.clientId)).city`. When that row scrolls back into view, the widget re-attaches to that exact `clientId` and recovers 100% of its original data.",
          ),
        ]),
      ]),

      // ---------------------------------------------------------------------
      // 3.3 Full Runnable Example
      // ---------------------------------------------------------------------
      div(id: 'lazy-scroll-example', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 03.3 · RUNNABLE EXAMPLE')]),
      h2(classes: 'docs-h2 display', [.text('Full Example: A Virtualized List with KeyedFieldList')]),
      p([
        .text(
          'The complete snippet below is adapted from a real `keyed_form_flutter` screen: a virtualized list of stops inside `ListView.builder`, supporting safe add, remove, and reorder:',
        ),
      ]),

      const DocsCodeBlock(
        title: 'lib/tour_builder/tour_form_body.dart',
        language: 'dart',
        rawSnippet: '''class TourStopsList extends StatelessWidget {
  const TourStopsList({required this.controller, super.key});

  final KeyedFormController<TourSchema> controller;

  @override
  Widget build(BuildContext context) {
    return KeyedForm<TourSchema>(
      controller: controller,
      child: KeyedFieldList<TourSchema, StopSchema>(
        field: TourFields.stops,
        builder: (context, stops, list) => ListView.builder(
          itemCount: stops.length,
          itemBuilder: (context, index) {
            final stop = stops[index];

            return Card(
              key: ValueKey(stop.clientId), // Permanent identity via clientId
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: KeyedFormField.text<TourSchema>(
                        field: TourFields.stop(stopClientId: stop.clientId).city,
                        builder: (context, f, textController) => TextField(
                          controller: textController,
                          onTapOutside: (_) => f.onBlur(),
                          decoration: InputDecoration(
                            labelText: 'Stop #\${index + 1}',
                            errorText: f.errorText,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: index > 0 ? () => list.move(index, index - 1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: index < stops.length - 1 ? () => list.move(index, index + 1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: stops.length > 1 ? () => list.removeById(stop.clientId) : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [.text('// A fully safe virtualized list with KeyedFieldList\n')]),
          span(classes: 'syntax-type', [.text('KeyedFieldList<TourSchema, StopSchema>')]),
          .text('(\n  field: '),
          span(classes: 'syntax-type', [.text('TourFields')]),
          .text(
            '.stops,\n  builder: (context, stops, list) => ListView.builder(\n    itemCount: stops.length,\n    itemBuilder: (context, index) {\n      ',
          ),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('stop = stops[index];\n\n      '),
          span(classes: 'syntax-kw', [.text('return ')]),
          span(classes: 'syntax-type', [.text('Card')]),
          .text('(\n        key: '),
          span(classes: 'syntax-type', [.text('ValueKey')]),
          .text('(stop.clientId), '),
          span(classes: 'syntax-comment', [.text('// Immutable key by clientId\n')]),
          .text('        child: Row(children: [\n          Expanded(\n            child: '),
          span(classes: 'syntax-type', [.text('KeyedFormField')]),
          .text('.text<TourSchema>(\n              field: '),
          span(classes: 'syntax-type', [.text('TourFields')]),
          .text(
            '.stop(stopClientId: stop.clientId).city,\n              builder: (context, f, textController) => TextField(\n                controller: textController,\n                onTapOutside: (_) => f.onBlur(),\n                decoration: InputDecoration(errorText: f.errorText),\n              ),\n            ),\n          ),\n          IconButton(\n            icon: const Icon(Icons.delete_outline),\n            onPressed: () => list.',
          ),
          span(classes: 'syntax-fn', [.text('removeById')]),
          .text('(stop.clientId),\n          ),\n        ]),\n      );\n    },\n  ),\n);'),
        ]),
      ),

      // ---------------------------------------------------------------------
      // 3.4 Scroll-to-First-Error in a Virtualized List
      // ---------------------------------------------------------------------
      div(id: 'scroll-to-first-error', classes: 'docs-anchor', []),
      span(classes: 'section-kicker mono mt-24', [.text('// 03.4 · SCROLL-TO-FIRST-ERROR')]),
      h2(classes: 'docs-h2 display', [.text('Scroll-to-First-Error in a Virtualized List')]),

      const DocsCallout(
        type: CalloutType.warning,
        title: "handleSubmit's default reveal isn't enough here",
        content: Component.fragment([
          p([
            .text(
              '`form.handleSubmit(context, onValid)` reveals the first invalid field for you by calling `KeyedFieldRegistry.revealFirst`, which in turn calls `Scrollable.ensureVisible` on that field\'s `KeyedFieldAnchor`. That only works if the anchor is currently ',
            ),
            b([.text('mounted')]),
            .text(
              " — and in a `ListView.builder`, a row far outside the viewport hasn't been built at all, so it has no anchor. `reveal()` just returns `false`, silently, and nothing scrolls.",
            ),
          ]),
        ]),
      ),

      p([
        .text(
          'The fix is a two-phase reveal, taken from the real `tour_builder_screen.dart` example in `keyed_form_flutter/example`:',
        ),
      ]),
      ul(classes: 'docs-list', [
        li([
          b([.text('1. Coarse jump to the right section.')]),
          .text(
            ' Wrap each logical section (the details card, then one section per row) in a widget keyed with a `GlobalKey`, so its `RenderSliver` exposes `constraints.precedingScrollExtent` — how many pixels of content come before it. Walk the `ScrollController` toward that offset a viewport at a time when the exact offset isn\'t measurable yet (the section hasn\'t been laid out because it\'s still off-screen), re-measuring after each jump.',
          ),
        ]),
        li([
          b([.text('2. Fine reveal.')]),
          .text(
            ' Once the target section has been built and its offset is known, wait one frame (`WidgetsBinding.instance.endOfFrame`) and call `KeyedFieldRegistry.revealFirst` as usual — its anchor is now mounted, so `Scrollable.ensureVisible` does the precise, animated scroll and focuses the field.',
          ),
        ]),
      ]),

      const DocsCodeBlock(
        title: 'lib/tour_builder/tour_builder_screen.dart (excerpt)',
        language: 'dart',
        rawSnippet: '''// Section keys: index 0 = the details card, 1..N = one per stop. Each
// section's sliver exposes `precedingScrollExtent` for the coarse jump.
final _detailsSectionKey = GlobalKey();
final _stopSectionKeys = <String, GlobalKey>{};

Future<void> _revealFirstError(BuildContext context) async {
  final keys = _form.visibleErrorKeys.toList();
  if (keys.isEmpty) return;
  await _jumpToSection(_sectionForKey(keys.first)); // phase 1: coarse jump
  if (!context.mounted) return;
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;
  KeyedForm.registryOf<TourSchema>(context)
      .revealFirst(_form.visibleErrorKeys, alignment: 0.5); // phase 2: fine reveal
}

double? _sectionOffset(int index) {
  final render = _sectionKey(index).currentContext?.findRenderObject();
  if (render is RenderSliver && render.geometry != null) {
    return render.constraints.precedingScrollExtent;
  }
  return null; // not laid out yet — _jumpToSection walks toward it
}''',
        code: Component.fragment([
          span(classes: 'syntax-comment', [
            .text(
              "// Section keys: index 0 = details card, 1..N = one per stop.\n// Each section's sliver exposes precedingScrollExtent for the coarse jump.\n",
            ),
          ]),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('_detailsSectionKey = '),
          span(classes: 'syntax-type', [.text('GlobalKey')]),
          .text('();\n'),
          span(classes: 'syntax-kw', [.text('final ')]),
          .text('_stopSectionKeys = <'),
          span(classes: 'syntax-type', [.text('String')]),
          .text(', '),
          span(classes: 'syntax-type', [.text('GlobalKey')]),
          .text('>{};\n\n'),
          span(classes: 'syntax-comment', [.text('// phase 1: coarse jump, phase 2: fine reveal\n')]),
          span(classes: 'syntax-kw', [.text('await ')]),
          .text('_jumpToSection(_sectionForKey(keys.first));\n'),
          .text('KeyedForm.registryOf<TourSchema>(context).'),
          span(classes: 'syntax-fn', [.text('revealFirst')]),
          .text('(_form.visibleErrorKeys, alignment: '),
          span(classes: 'syntax-num', [.text('0.5')]),
          .text(');'),
        ]),
      ),

      p(classes: 'note', [
        .text(
          'Full walk logic (the retry loop that advances the scroll position a viewport at a time until the target section can be measured) lives in `_jumpToSection` in the example — this excerpt shows the shape, not the whole implementation.',
        ),
      ]),
    ]);
  }
}
