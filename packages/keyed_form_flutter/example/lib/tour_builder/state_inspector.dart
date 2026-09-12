// Not part of the form — widgets that only *observe* the controller:
// the app-bar "Unsaved" chip and the live state panel shown beside the form
// on wide viewports.

import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import 'tour_schema.dart';

class DirtyBadge extends StatelessWidget {
  const DirtyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final dirty = context.selectForm(
      (KeyedFormController<TourSchema> form) => form.isDirty,
    );
    return AnimatedOpacity(
      opacity: dirty ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Chip(
          label: const Text('Unsaved'),
          visualDensity: VisualDensity.compact,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        ),
      ),
    );
  }
}

class StateInspector extends StatelessWidget {
  const StateInspector({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return KeyedFormBuilder<TourSchema>(
      builder: (context, form) {
        final tour = form.value;
        final nights = tour.stops.fold<int>(0, (sum, s) => sum + s.nights);
        final errors = form.errors;
        final visible = form.visibleErrorKeys.toSet();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('State', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _row('dirty', '${form.isDirty}'),
            _row('submitted', '${form.submitted}'),
            _row('title', '"${tour.title}"'),
            _row('category', tour.category.name),
            _row('maxGuests', '${tour.maxGuests}'),
            _row('isPublic', '${tour.isPublic}'),
            _row('stops', '${tour.stops.length}  ($nights nights)'),
            const Divider(height: 24),
            Text(
              'errors (${errors.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            if (errors.isEmpty) Text('none', style: style),
            for (final key in errors.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${key.toPath()}: ${errors.byKey(key)}'
                  '${visible.contains(key) ? '' : '  (hidden)'}',
                  style: style?.copyWith(
                    color: visible.contains(key)
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
