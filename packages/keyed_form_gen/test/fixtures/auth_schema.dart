import 'package:keyed_schema/keyed_schema.dart';

part 'auth_schema.kfg.dart';

@keyedSchema
final authSchema = ks.object({
  'username': ks.string().min(3, error: .text('Minimum 3 characters')),
  'password': ks.string().min(6, error: .text('Minimum 6 characters')),
  'remember': ks.boolean().defaultTo(false),
});
