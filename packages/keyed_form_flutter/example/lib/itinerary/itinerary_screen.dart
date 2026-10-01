import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../fields.dart';
import '../widgets/demo_note.dart';
import '../widgets/demo_scaffold.dart';
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
  late final form = KeyedFormController<ItinerarySchema>(
    initialValue: ItinerarySchema.create(
      days: [
        DaySchema.create(
          label: 'Day 1',
          activities: [
            SightseeingActivitySchema.create(place: 'Fushimi Inari'),
          ],
        ),
      ],
    ),
    mode: KeyedFormMode.onTouched,
    resolver: ItinerarySchema.validateData,
    asyncValidators: [
      .forEach(
        list: ItineraryFields.days,
        rules: [
          .forEach(
            list: DayFields.activities,
            rules: [
              .field(
                field:
                    VariantRef<ActivitySchema, SightseeingActivitySchema>.type()
                        .then(SightseeingActivityFields.place),
                validate: (_, place) => _checkPlace(place),
                timeout: const Duration(seconds: 5),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  bool _submitted = false;

  Future<String?> _checkPlace(String place) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final normalized = place.trim().toLowerCase();
    if (normalized == 'error') throw StateError('Place service unavailable');
    return normalized == 'closed' ? 'This place is unavailable' : null;
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Itinerary',
      maxWidth: 560,
      child: KeyedForm<ItinerarySchema>(
        controller: form,
        child: KeyedFieldList<ItinerarySchema, DaySchema>(
          field: ItineraryFields.days,
          builder: (context, days, dayList) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const DemoNote(
                'Place availability is checked on blur and again on submit. '
                'Try “closed” for a value error and “error” for a service '
                'failure. Switch to Meal or remove an activity while checking '
                'to discard its stale result.',
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
              const SizedBox(height: 16),
              KeyedFormBuilder<ItinerarySchema>(
                builder: (context, controller) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton(
                      onPressed: controller.submitting
                          ? null
                          : () async {
                              await form.handleSubmit(context, (_) {
                                setState(() => _submitted = true);
                              });
                            },
                      child: Text(
                        controller.submitting ? 'Checking…' : 'Submit',
                      ),
                    ),
                    if (_submitted)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Submitted'),
                      ),
                  ],
                ),
              ),
            ],
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
                    field: ItineraryFields.day(dayClientId: dayId).label,
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
              field: ItineraryFields.dayActivities(dayClientId: dayId),
              builder: (context, activities, activityList) => Column(
                children: [
                  for (final activity in activities)
                    _ActivityRow(
                      key: ValueKey(activity.clientId),
                      form: form,
                      fields: ItineraryFields.activity(
                        dayClientId: dayId,
                        activityClientId: activity.clientId,
                      ),
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
                      onPressed: () => activityList.append(
                        SightseeingActivitySchema.create(),
                      ),
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
    required this.form,
    required this.fields,
    required this.onChangeKind,
    required this.onRemove,
  });

  final KeyedFormController<ItinerarySchema> form;
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
                ButtonSegment(value: 'sightseeing', label: Text('Sightseeing')),
                ButtonSegment(value: 'meal', label: Text('Meal')),
              ],
              selected: {kind},
              onSelectionChanged: (selection) => onChangeKind(selection.first),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: switch (kind) {
                    'sightseeing' => KeyedFormField.text<ItinerarySchema>(
                      field: fields.asSightseeing.place,
                      builder: (context, field, controller) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Focus(
                            canRequestFocus: false,
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) field.onBlur();
                            },
                            child: TextField(
                              controller: controller,
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                              decoration: InputDecoration(
                                labelText: 'Place',
                                errorText: field.errorText,
                                helperText: field.isFailedValidation
                                    ? 'Availability check failed.'
                                    : null,
                                suffixIcon: field.isValidating
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          if (field.isFailedValidation)
                            TextButton(
                              onPressed: () async {
                                await form
                                    .field(fields.asSightseeing.place)
                                    .validate();
                              },
                              child: const Text('Retry place check'),
                            ),
                        ],
                      ),
                    ),
                    _ => KeyedText<ItinerarySchema>(
                      field: fields.asMeal.restaurant,
                      label: 'Restaurant',
                    ),
                  },
                ),
                IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
              ],
            ),
          ],
        );
      },
    ),
  );
}
