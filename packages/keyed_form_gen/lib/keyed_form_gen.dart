/// `build_runner` code generator for `@keyedSchema`-annotated libraries.
///
/// You normally do not import this library directly — it is wired in through
/// `build.yaml` / `build_runner`. It is exported so the `Builder` factory
/// (`keyedFormBuilder`) and the [KeyedFormGenerator] are addressable from
/// custom build setups.
library;

export 'builder.dart';
export 'src/keyed_form_generator.dart';
