@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'rebuild_lab_schema.kfg.dart';

/// 24 flat fields, declared by hand — enough to see, at a glance, that
/// editing one does not rebuild the others. See `rebuild_lab_screen.dart`.
final _rebuildLabSchema = ks.object({
  'field0': ks.string(error: .text('Required')).min(1),
  'field1': ks.string(error: .text('Required')).min(1),
  'field2': ks.string(error: .text('Required')).min(1),
  'field3': ks.string(error: .text('Required')).min(1),
  'field4': ks.string(error: .text('Required')).min(1),
  'field5': ks.string(error: .text('Required')).min(1),
  'field6': ks.string(error: .text('Required')).min(1),
  'field7': ks.string(error: .text('Required')).min(1),
  'field8': ks.string(error: .text('Required')).min(1),
  'field9': ks.string(error: .text('Required')).min(1),
  'field10': ks.string(error: .text('Required')).min(1),
  'field11': ks.string(error: .text('Required')).min(1),
  'field12': ks.string(error: .text('Required')).min(1),
  'field13': ks.string(error: .text('Required')).min(1),
  'field14': ks.string(error: .text('Required')).min(1),
  'field15': ks.string(error: .text('Required')).min(1),
  'field16': ks.string(error: .text('Required')).min(1),
  'field17': ks.string(error: .text('Required')).min(1),
  'field18': ks.string(error: .text('Required')).min(1),
  'field19': ks.string(error: .text('Required')).min(1),
  'field20': ks.string(error: .text('Required')).min(1),
  'field21': ks.string(error: .text('Required')).min(1),
  'field22': ks.string(error: .text('Required')).min(1),
  'field23': ks.string(error: .text('Required')).min(1),
});
