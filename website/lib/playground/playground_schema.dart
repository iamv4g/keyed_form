@keyedSchema
library;

import 'package:keyed_form_schema/keyed_form_schema.dart';

part 'playground_schema.kfg.dart';

enum PlanTier { free, pro, team }

final _playgroundSchema = ks.object({
  'name': ks
      .string(error: .text('Name is required'))
      .min(2, error: .text('At least 2 characters')),
  'email': ks
      .string(error: .text('Email is required'))
      .email(error: .text('Invalid email')),
  'age': ks
      .int(error: .text('Age is required'))
      .min(0, error: .text('Must be 0 or older'))
      .max(120, error: .text('Be realistic')),
  'newsletter': ks.boolean().defaultTo(false),
  'plan': ks
      .enums(PlanTier.values, error: .text('Pick a plan'))
      .defaultTo(PlanTier.free),
});
