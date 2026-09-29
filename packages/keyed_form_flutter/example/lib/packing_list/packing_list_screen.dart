import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../widgets/demo_note.dart';
import '../widgets/demo_scaffold.dart';
import 'packing_list.dart';
import 'packing_schema.dart';

class PackingListScreen extends StatefulWidget {
  const PackingListScreen({super.key});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  final form = KeyedFormController<PackingSchema>(
    initialValue: PackingSchema.create(
      items: [
        PackingItemSchema.create(label: 'Passport'),
        PackingItemSchema.create(label: 'Charger'),
        PackingItemSchema.create(label: 'Rain jacket'),
      ],
    ),
    mode: KeyedFormMode.onTouched,
    resolver: PackingSchema.validateData,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Packing list',
      maxWidth: 480,
      child: KeyedForm<PackingSchema>(
        controller: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            DemoNote(
              'Drag a row by its handle to reorder it; add, check off and '
              'remove rows. Every edit goes through the KeyedFieldList '
              "builder's own list, keyed by each row's clientId.",
            ),
            SizedBox(height: 16),
            PackingList(),
          ],
        ),
      ),
    );
  }
}
