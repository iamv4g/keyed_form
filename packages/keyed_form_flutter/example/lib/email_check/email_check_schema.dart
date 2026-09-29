@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'email_check_schema.kfg.dart';

final _emailCheckSchema = ks.object({
  'email': ks
      .string(error: .text('Enter your email'))
      .email(error: .text('That does not look like an email')),
});
