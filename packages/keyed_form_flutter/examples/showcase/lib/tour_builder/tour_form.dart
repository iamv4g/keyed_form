// The form itself — the scrollable body and one card per stop. The screen
// (tour_builder_screen.dart) owns the controller, the actions and the
// scroll-to-error orchestration; this file is just layout + field bindings.

import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../fields.dart';
import 'tour_schema.dart';

/// A lazy `CustomScrollView`: each stop is its own keyed sliver so
/// `precedingScrollExtent` can drive the jump, and off-screen cards are not
/// laid out or painted.
///
/// [sectionKey] `(0)` keys the details card, `(i + 1)` the i-th stop.
/// [stops] is read lazily so callbacks always act on the current list.
class TourFormBody extends StatelessWidget {
  const TourFormBody({
    required this.scroll,
    required this.stopIds,
    required this.sectionKey,
    required this.stops,
    super.key,
  });

  final ScrollController scroll;
  final List<String> stopIds;
  final GlobalKey Function(int index) sectionKey;
  final KeyedFormList<TourSchema, StopSchema> Function() stops;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                key: sectionKey(0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        KeyedText<TourSchema>(
                          field: TourFields.title,
                          label: 'Tour name',
                        ),
                        const SizedBox(height: 16),
                        KeyedDropdown<TourSchema, TourCategory>(
                          field: TourFields.category,
                          label: 'Category',
                          items: TourCategory.values,
                          itemLabel: _categoryLabel,
                        ),
                        const SizedBox(height: 16),
                        KeyedStepper<TourSchema>(
                          field: TourFields.maxGuests,
                          label: 'Max guests',
                          min: 1,
                          max: 30,
                        ),
                        KeyedSwitch<TourSchema>(
                          field: TourFields.isPublic,
                          title: 'Public tour',
                          subtitle: 'Listed in the catalogue',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Stops',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            for (var i = 0; i < stopIds.length; i++)
              SliverPadding(
                key: sectionKey(i + 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                sliver: SliverToBoxAdapter(
                  child: _StopCard(
                    key: ValueKey(stopIds[i]),
                    id: stopIds[i],
                    canRemove: stopIds.length > 1,
                    onRemove: () => stops().removeById(stopIds[i]),
                    onMoveUp: i > 0 ? () => stops().move(i, i - 1) : null,
                    onMoveDown: i < stopIds.length - 1
                        ? () => stops().move(i, i + 1)
                        : null,
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => stops().append(StopSchema.create()),
                      icon: const Icon(Icons.add),
                      label: const Text('Add stop'),
                    ),
                    const _ListError(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverToBoxAdapter(
                child: KeyedText<TourSchema>(
                  field: TourFields.notes,
                  label: 'Notes (optional)',
                  maxLines: 4,
                  anchor: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _categoryLabel(TourCategory c) => switch (c) {
  TourCategory.adventure => 'Adventure',
  TourCategory.culture => 'Culture',
  TourCategory.food => 'Food',
  TourCategory.nature => 'Nature',
};

class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.id,
    required this.canRemove,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    super.key,
  });

  final String id;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final ref = (stop: id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: KeyedText<TourSchema>(
                    field: TourFields.stop(ref).city,
                    label: 'City',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: KeyedStepper<TourSchema>(
                    field: TourFields.stop(ref).nights,
                    label: 'Nights',
                    min: 1,
                    max: 14,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onMoveUp,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Move up',
                ),
                IconButton(
                  onPressed: onMoveDown,
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: 'Move down',
                ),
                IconButton(
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove stop',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The list-level error (`stops` key) — not covered by a `KeyedFormField`,
/// so it watches the whole controller.
class _ListError extends StatelessWidget {
  const _ListError();

  @override
  Widget build(BuildContext context) => KeyedFormBuilder<TourSchema>(
    builder: (context, form) {
      final error = form.visibleError(TourFields.stops.key);
      if (error == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(left: 12, top: 4),
        child: Text(
          error,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    },
  );
}
