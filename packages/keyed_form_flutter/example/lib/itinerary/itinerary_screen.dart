import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../fields.dart';
import '../widgets/demo_note.dart';
import 'itinerary_schema.dart';

/// Schema nested two levels deep (days -> activities) where each activity is
/// a discriminated union (sightseeing / meal) — the field-reference chain a
/// hand-written model would have to reimplement by hand at every level.
class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final form = KeyedFormController<ItinerarySchema>(
    initialValue: ItinerarySchema.create(
      days: [
        DaySchema.create(
          label: 'Day 1',
          activities: [SightseeingActivitySchema.create(place: 'Fushimi Inari')],
        ),
      ],
    ),
    mode: KeyedFormMode.onSubmit,
    resolver: ItinerarySchema.validateData,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: KeyedForm<ItinerarySchema>(
            controller: form,
            child: KeyedFieldList<ItinerarySchema, DaySchema>(
              field: ItineraryFields.days,
              builder: (context, days, dayList) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const DemoNote(
                    'Each day is a row containing its own by-id list of '
                    'activities, and each activity is a discriminated union '
                    '— switch its kind and the previous narrowed field '
                    '(.asSightseeing / .asMeal) simply stops resolving, no '
                    'error.',
                  ),
                  const SizedBox(height: 16),
                  for (final day in days)
                    _DayCard(
                      key: ValueKey(day.clientId),
                      form: form,
                      dayId: day.clientId,
                      onRemoveDay: days.length > 1
                          ? () => dayList.removeById(day.clientId)
                          : null,
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => dayList.append(
                      DaySchema.create(
                        label: 'Day ${days.length + 1}',
                        activities: [SightseeingActivitySchema.create()],
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add day'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    super.key,
    required this.form,
    required this.dayId,
    required this.onRemoveDay,
  });

  final KeyedFormController<ItinerarySchema> form;
  final String dayId;
  final VoidCallback? onRemoveDay;

  @override
  Widget build(BuildContext context) {
    final dayRef = (day: dayId);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: KeyedText<ItinerarySchema>(
                    field: ItineraryFields.day(dayRef).label,
                    label: 'Day label',
                  ),
                ),
                IconButton(
                  onPressed: onRemoveDay,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            KeyedFieldList<ItinerarySchema, ActivitySchema>(
              field: ItineraryFields.dayActivities(dayRef),
              builder: (context, activities, activityList) => Column(
                children: [
                  for (final activity in activities)
                    _ActivityRow(
                      key: ValueKey(activity.clientId),
                      fields: ItineraryFields.activity((
                        day: dayId,
                        activity: activity.clientId,
                      )),
                      onChangeKind: (kind) => activityList.updateById(
                        activity.clientId,
                        (current) => kind == 'sightseeing'
                            ? SightseeingActivitySchema.create(
                                clientId: current.clientId,
                              )
                            : MealActivitySchema.create(
                                clientId: current.clientId,
                              ),
                      ),
                      onRemove: activities.length > 1
                          ? () => activityList.removeById(activity.clientId)
                          : null,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          activityList.append(SightseeingActivitySchema.create()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add activity'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    super.key,
    required this.fields,
    required this.onChangeKind,
    required this.onRemove,
  });

  final ActivityFieldRefs fields;
  final ValueChanged<String> onChangeKind;
  final VoidCallback? onRemove;

  // Swapping an activity's variant keeps its clientId, so the row *set*
  // KeyedFieldList tracks above never changes — it has no reason to rebuild
  // this row, and its `activities` snapshot goes stale the instant the kind
  // changes. Read the live kind here instead, scoped to just this row.
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: KeyedFormSelector<ItinerarySchema, String?>(
      selector: (f) => fields.getOrNull(f.value)?.kind,
      builder: (context, kind, _) {
        if (kind == null) return const SizedBox.shrink(); // row removed
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'sightseeing',
                  label: Text('Sightseeing'),
                ),
                ButtonSegment(value: 'meal', label: Text('Meal')),
              ],
              selected: {kind},
              onSelectionChanged: (selection) =>
                  onChangeKind(selection.first),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: switch (kind) {
                    'sightseeing' => KeyedText<ItinerarySchema>(
                      field: fields.asSightseeing.place,
                      label: 'Place',
                    ),
                    _ => KeyedText<ItinerarySchema>(
                      field: fields.asMeal.restaurant,
                      label: 'Restaurant',
                    ),
                  },
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
