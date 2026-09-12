/// The `build_runner` entry point — see [keyedFormBuilder].
library;

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generators/preamble.dart';
import 'src/keyed_form_generator.dart';

/// Builder factory for keyed_form_gen.
///
/// A [PartBuilder] (own `.kfg.dart` extension), NOT a
/// [SharedPartBuilder]: the generated schema classes must be resolvable as a
/// real source file *before* the shared-part phase runs, so that a
/// `@riverpod` / dart_mappable signature is allowed to name one
/// (`KeyedFormController<ItineraryBuilderSchema>`). A shared part would be
/// materialised in the same phase and read back as an invalid type.
Builder keyedFormBuilder(BuilderOptions options) {
  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );
  return PartBuilder(
    [const KeyedFormGenerator()],
    '.kfg.dart',
    // Puts the ignore-comment before `part of`, alongside the standard
    // "GENERATED CODE" banner — ahead of the generated body, so it survives
    // `dart format` untouched instead of drifting relative to whatever
    // follows it in the body.
    header:
        '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n$generatedIgnoreComment',
    writeDescriptions: false,
    formatOutput: (code, version) {
      try {
        return formatter.format(code);
      } catch (_) {
        return code;
      }
    },
  );
}
