/// The landing page's login demo — `packages/keyed_form_flutter/example/
/// lib/login/login_schema.dart` without the `remember` checkbox. Keep the
/// two in step: the page shows this schema's source as "the code behind
/// the demo".
@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'login_schema.kfg.dart';

final _loginSchema = ks.object({
  'email': ks.string(error: .text('Enter your email')).email(error: .text('That does not look like an email')),
  'password': ks.string(error: .text('Enter your password')).min(8, error: .text('At least 8 characters')),
});
