import 'package:keyed_schema/keyed_schema.dart';

part 'function_schema.kfg.dart';

@keyedSchema
KSObject loginSchema() {
  return ks.object({
    'username': ks.string(error: .text('Username is required')),
    'password': ks.string(error: .text('Password is required')),
    'remember': ks.boolean().defaultTo(false),
  });
}
