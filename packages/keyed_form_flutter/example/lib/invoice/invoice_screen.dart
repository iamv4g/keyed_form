import 'package:flutter/material.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import '../fields.dart';
import '../widgets/demo_note.dart';
import '../widgets/demo_scaffold.dart';
import 'invoice_schema.dart';

/// Read-only fields (`markReadOnly` / `force: true`) and a derived field
/// (`addRelation`): the total is never typed, only ever written by the
/// relation, and is frozen from the moment the controller is built.
class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final form = KeyedFormController<InvoiceSchema>(
    initialValue: InvoiceSchema.create(
      lineItems: [
        LineItemSchema.create(
          description: 'Guide service',
          quantity: 1,
          unitPrice: 150,
        ),
      ],
    ),
    mode: KeyedFormMode.onTouched,
    resolver: InvoiceSchema.validateData,
  );

  late final VoidCallback _unsubscribeTotal;
  bool _locked = false;

  static int _sumLineItems(List<LineItemSchema> items) =>
      items.fold(0, (sum, item) => sum + item.quantity * item.unitPrice);

  @override
  void initState() {
    super.initState();
    // The total is derived, never typed — freeze it immediately.
    form.markReadOnly(InvoiceFields.total.key);
    _unsubscribeTotal = form.addRelation(
      InvoiceFields.lineItems,
      _sumLineItems,
      (total) => form.field(InvoiceFields.total).set(total, force: true),
    );
    // addRelation only fires on a later change, so seed the initial total by
    // hand — same force: true, since the field is already frozen.
    form
        .field(InvoiceFields.total)
        .set(_sumLineItems(form.value.lineItems), force: true);
  }

  @override
  void dispose() {
    _unsubscribeTotal();
    form.dispose();
    super.dispose();
  }

  void _toggleLock() {
    setState(() {
      _locked = !_locked;
      if (_locked) {
        form.markReadOnly(InvoiceFields.lineItems.key);
      } else {
        form.unmarkReadOnly(InvoiceFields.lineItems.key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Invoice',
      maxWidth: 480,
      actions: [
        IconButton(
          tooltip: _locked ? 'Unlock line items' : 'Lock line items',
          icon: Icon(_locked ? Icons.lock : Icons.lock_open),
          onPressed: _toggleLock,
        ),
      ],
      child: KeyedForm<InvoiceSchema>(
        controller: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DemoNote(
              'Lock line items to freeze the whole list — and every '
              'field inside every row — with one markReadOnly call on '
              'the list key. The total below is separately, permanently '
              'read-only: addRelation is the only thing that ever '
              'writes it, with force: true.',
            ),
            const SizedBox(height: 16),
            KeyedFieldList<InvoiceSchema, LineItemSchema>(
              field: InvoiceFields.lineItems,
              builder: (context, items, list) => Column(
                children: [
                  for (final item in items)
                    _LineItemRow(
                      key: ValueKey(item.clientId),
                      fields: InvoiceFields.lineItem((lineItem: item.clientId)),
                      onRemove: items.length > 1
                          ? () => list.removeById(item.clientId)
                          : null,
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => list.append(
                      LineItemSchema.create(quantity: 1, unitPrice: 0),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add line item'),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            KeyedFormSelector<InvoiceSchema, int>(
              selector: (f) => f.read(InvoiceFields.total) ?? 0,
              builder: (context, total, _) => ListTile(
                title: const Text('Total'),
                trailing: Text(
                  '\$$total',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({super.key, required this.fields, required this.onRemove});

  final LineItemFieldRefs fields;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KeyedText<InvoiceSchema>(
                field: fields.description,
                label: 'Description',
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: KeyedStepper<InvoiceSchema>(
                field: fields.quantity,
                label: 'Qty',
                min: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KeyedStepper<InvoiceSchema>(
                field: fields.unitPrice,
                label: 'Price',
                max: 9999,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
