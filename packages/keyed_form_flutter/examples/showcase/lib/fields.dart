// Design-system-agnostic helpers over `keyed_form_flutter`. The `Keyed*`
// widgets are thin wrappers over [KeyedFormField] — `keyed_form_flutter` binds
// *state*, these decide *presentation*. For widgets that observe the form but
// aren't one field, use `keyed_form_flutter`'s [KeyedFormSelector] (a slice)
// or [KeyedFormBuilder] (the whole controller).

import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

class KeyedText<R> extends StatelessWidget {
  const KeyedText({
    required this.field,
    required this.label,
    this.maxLines = 1,
    this.anchor = true,
    super.key,
  });

  final FieldRef<R, String> field;
  final String label;
  final int maxLines;
  final bool anchor;

  @override
  Widget build(BuildContext context) => KeyedFormField.text<R>(
    field: field,
    anchor: anchor,
    builder: (context, f, controller) => TextField(
      controller: controller,
      onTapOutside: (_) => f.onBlur(),
      minLines: maxLines > 1 ? maxLines : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        errorText: f.errorText,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class KeyedDropdown<R, T> extends StatelessWidget {
  const KeyedDropdown({
    required this.field,
    required this.label,
    required this.items,
    required this.itemLabel,
    super.key,
  });

  final FieldRef<R, T> field;
  final String label;
  final List<T> items;
  final String Function(T value) itemLabel;

  @override
  Widget build(BuildContext context) => KeyedFormField<R, T>(
    field: field,
    builder: (context, f) => InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: f.errorText,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          itemHeight: null,
          value: f.value,
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(itemLabel(item))),
          ],
          onChanged: (value) {
            if (value != null) {
              f.onChanged(value);
              f.onBlur();
            }
          },
        ),
      ),
    ),
  );
}

class KeyedSwitch<R> extends StatelessWidget {
  const KeyedSwitch({
    required this.field,
    required this.title,
    this.subtitle,
    super.key,
  });

  final FieldRef<R, bool> field;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => KeyedFormField<R, bool>(
    field: field,
    anchor: false,
    builder: (context, f) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: f.value ?? false,
      onChanged: (value) {
        f.onChanged(value);
        f.onBlur();
      },
    ),
  );
}

class KeyedStepper<R> extends StatelessWidget {
  const KeyedStepper({
    required this.field,
    required this.label,
    this.min = 0,
    this.max = 999,
    super.key,
  });

  final FieldRef<R, int> field;
  final String label;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) => KeyedFormField<R, int>(
    field: field,
    builder: (context, f) {
      final value = f.value ?? min;
      return InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: f.errorText,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size.square(24)),
              onPressed: value > min
                  ? () {
                      f.onChanged(value - 1);
                      f.onBlur();
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(child: Text('$value', textAlign: TextAlign.center)),
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size.square(24)),
              onPressed: value < max
                  ? () {
                      f.onChanged(value + 1);
                      f.onBlur();
                    }
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      );
    },
  );
}
