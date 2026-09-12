import 'package:flutter/material.dart';

import '../invoice/invoice_screen.dart';
import '../itinerary/itinerary_screen.dart';
import '../login/login_screen.dart';
import '../packing_list/packing_list_screen.dart';
import '../rebuild_lab/rebuild_lab_screen.dart';
import '../tour_builder/tour_builder_screen.dart';

class _Demo {
  const _Demo(this.title, this.description, this.builder);
  final String title;
  final String description;
  final WidgetBuilder builder;
}

final _demos = <_Demo>[
  _Demo(
    'Sign in',
    'Text fields, onTouched mode, async validation '
        '(isValidating / isFailedValidation).',
    (_) => const LoginScreen(),
  ),
  _Demo(
    'Invoice',
    'Read-only fields (markReadOnly, force: true) and a derived field '
        '(addRelation).',
    (_) => const InvoiceScreen(),
  ),
  _Demo(
    'Packing list',
    'A dynamic list bound with KeyedFieldList directly.',
    (_) => const PackingListScreen(),
  ),
  _Demo(
    'Itinerary',
    'A schema nested two levels deep, with a discriminated union at the '
        'leaf.',
    (_) => const ItineraryScreen(),
  ),
  _Demo(
    'Rebuild lab',
    'O(1) rebuilds, seen live: 24 fields, one rebuild counter each.',
    (_) => const RebuildLabScreen(),
  ),
  _Demo(
    'Tour builder',
    'Everything together: dynamic list, cross-field rules, a live '
        'validation-mode switch, server-error merging, dirty tracking, and '
        'two-phase scroll-to-first-error.',
    (_) => const TourBuilderScreen(),
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('keyed_form_flutter')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _demos.length,
            separatorBuilder: (context, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final demo = _demos[i];
              return Card(
                child: ListTile(
                  title: Text(demo.title),
                  subtitle: Text(demo.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: demo.builder),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
