import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../widgets/demo_note.dart';
import '../widgets/demo_scaffold.dart';
import 'rebuild_lab_schema.dart';

/// The benchmark numbers made visible: 24 fields, each carrying its own
/// rebuild counter. Type into one and only its counter moves. The header
/// counter, by contrast, is a `KeyedFormBuilder` — the whole-controller
/// escape hatch — so it ticks on *every* write, on purpose: it's the
/// controller notifying, not a field rebuilding.
class RebuildLabScreen extends StatefulWidget {
  const RebuildLabScreen({super.key});

  @override
  State<RebuildLabScreen> createState() => _RebuildLabScreenState();
}

class _RebuildLabScreenState extends State<RebuildLabScreen> {
  final form = KeyedFormController<RebuildLabSchema>(
    initialValue: RebuildLabSchema.create(
      field0: 'v0',
      field1: 'v1',
      field2: 'v2',
      field3: 'v3',
      field4: 'v4',
      field5: 'v5',
      field6: 'v6',
      field7: 'v7',
      field8: 'v8',
      field9: 'v9',
      field10: 'v10',
      field11: 'v11',
      field12: 'v12',
      field13: 'v13',
      field14: 'v14',
      field15: 'v15',
      field16: 'v16',
      field17: 'v17',
      field18: 'v18',
      field19: 'v19',
      field20: 'v20',
      field21: 'v21',
      field22: 'v22',
      field23: 'v23',
    ),
    mode: KeyedFormMode.onChange,
    resolver: RebuildLabSchema.validateData,
  );

  final _fieldRebuilds = List<int>.filled(_refs.length, 0);
  int _formTicks = 0;

  static final _refs = <FieldRef<RebuildLabSchema, String>>[
    RebuildLabFields.field0,
    RebuildLabFields.field1,
    RebuildLabFields.field2,
    RebuildLabFields.field3,
    RebuildLabFields.field4,
    RebuildLabFields.field5,
    RebuildLabFields.field6,
    RebuildLabFields.field7,
    RebuildLabFields.field8,
    RebuildLabFields.field9,
    RebuildLabFields.field10,
    RebuildLabFields.field11,
    RebuildLabFields.field12,
    RebuildLabFields.field13,
    RebuildLabFields.field14,
    RebuildLabFields.field15,
    RebuildLabFields.field16,
    RebuildLabFields.field17,
    RebuildLabFields.field18,
    RebuildLabFields.field19,
    RebuildLabFields.field20,
    RebuildLabFields.field21,
    RebuildLabFields.field22,
    RebuildLabFields.field23,
  ];

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Rebuild lab',
      child: KeyedForm<RebuildLabSchema>(
        controller: form,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: DemoNote(
                'Type into any one field below. Only that field\'s own '
                'rebuild count moves — the other 23 stay put.',
              ),
            ),
            KeyedFormBuilder<RebuildLabSchema>(
              builder: (context, _) {
                _formTicks++;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Controller notifications: $_formTicks '
                    '(this header rebuilds on every write — it is the '
                    'whole-controller escape hatch, KeyedFormBuilder)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 64,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _refs.length,
                itemBuilder: (context, i) =>
                    KeyedFormField.text<RebuildLabSchema>(
                      field: _refs[i],
                      anchor: false,
                      builder: (context, f, controller) {
                        _fieldRebuilds[i]++;
                        return TextField(
                          controller: controller,
                          onTapOutside: (_) => f.onBlur(),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText:
                                'Field $i · rebuilt ${_fieldRebuilds[i]}×',
                            errorText: f.errorText,
                            border: const OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
