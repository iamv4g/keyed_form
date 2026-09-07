@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'login_schema.kfg.dart';

final loginSchema = ks.object({
  'email': ks
      .string(error: .text('Enter your email'))
      .email(error: .text('That does not look like an email')),
  'password': ks
      .string(error: .text('Enter your password'))
      .min(8, error: .text('At least 8 characters')),
  'remember': ks.boolean().defaultTo(false),
});
