@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'auth_schema.kfg.dart';

final authSchema = ks.object({
  'username': ks.string().min(3, error: .text('Minimum 3 characters')),
  'password': ks.string().min(6, error: .text('Minimum 6 characters')),
  'remember': ks.boolean().defaultTo(false),
});
