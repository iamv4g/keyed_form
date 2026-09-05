// Tests `KeyedFormGenerator.generateForAnnotatedElement` — the class
// `builder.dart` wires into a `PartBuilder` and that `build_runner` actually
// invokes. Every other test in this package exercises `SchemaParser`/
// `DataClassGenerator` directly and never touches this class, so nothing
// previously caught a regression in the library-vs-declaration branching,
// the dedup-by-name pass, or the two "nothing to generate" fallback
// messages.
//
// Not covered here: `annotation.peek('suffix')` (the `@KeyedSchema(suffix:
// ...)` override). `ElementAnnotation.computeConstantValue()` returns null
// for every annotation resolved through `resolveSource`'s lightweight
// per-file analysis context (verified directly — not specific to this
// annotation or to a constructor-invocation vs. const-reference shape), so
// there's no way to feed `generateForAnnotatedElement` a real constant value
// this way. The suffix always falls back to the `'Schema'` default below,
// which happens to be what every test here wants anyway.
//
// `package:build_test`'s `testBuilder` can't be used here: its virtual
// single-package sandbox has no way to resolve a real dependency like
// `package:keyed_schema/keyed_schema.dart` (its package graph is built only
// from the assets you hand it). `resolveSource`, by contrast, resolves
// against this package's real, already-installed dependencies via
// `PackageAssetReader.currentIsolate()` — so a source string that imports
// `keyed_schema` resolves exactly as it would in a real build. What
// `generateForAnnotatedElement` needs beyond a resolved `Element` is a
// `BuildStep` (only for `buildStep.resolver` / `buildStep.inputId`, per its
// `_getCompilationUnit` helper) — `_FakeBuildStep` below supplies just that,
// mirroring the `_NamedElement implements Element` + `noSuchMethod` pattern
// `keyed_form_generator.dart` and `tool/regen_schema.dart` already use for
// the same reason.
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:keyed_form_gen/src/keyed_form_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

class _FakeBuildStep implements BuildStep {
  _FakeBuildStep(this.resolver, this.inputId);

  @override
  final Resolver resolver;

  @override
  final AssetId inputId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Resolves [source] under a synthetic asset id in *this* package (so
/// `import 'package:keyed_schema/...'` resolves against the real
/// dependency), finds the top-level element named [elementName], reads its
/// first annotation, and runs it through [KeyedFormGenerator].
Future<String> _generate(String source, String elementName) async {
  late final String output;
  final inputId = AssetId.parse('keyed_form_gen|lib/generator_test_input.dart');
  await resolveSource(source, (resolver) async {
    final lib = await resolver.libraryFor(inputId);
    final element = [
      ...lib.topLevelVariables,
      ...lib.topLevelFunctions,
    ].firstWhere((e) => e.name == elementName);
    final annotation = ConstantReader(
      element.metadata.annotations.first.computeConstantValue(),
    );
    final buildStep = _FakeBuildStep(resolver, inputId);
    output = await const KeyedFormGenerator().generateForAnnotatedElement(
      element,
      annotation,
      buildStep,
    );
  }, inputId: inputId);
  return output;
}

void main() {
  group('KeyedFormGenerator.generateForAnnotatedElement', () {
    test(
      'a single @keyedSchema top-level variable generates its data class',
      () async {
        final output = await _generate('''
import 'package:keyed_schema/keyed_schema.dart';

@keyedSchema
final widgetSchema = ks.object({
  'name': ks.string(),
});
''', 'widgetSchema');

        expect(output, contains('class WidgetSchema'));
        expect(output, contains('abstract final class WidgetFields'));
      },
    );

    test('@keyedSchema library; parses every top-level schema declaration, '
        'deduping shared nested classes', () async {
      final inputId = AssetId.parse(
        'keyed_form_gen|lib/generator_test_input.dart',
      );
      await resolveSource(
        '''
@keyedSchema
library;

import 'package:keyed_schema/keyed_schema.dart';

final widgetSchema = ks.object({
  'name': ks.string(),
});

final gadgetSchema = ks.object({
  'label': ks.string(),
});
''',
        (resolver) async {
          final libraryElement = await resolver.libraryFor(inputId);
          final annotation = ConstantReader(
            libraryElement.metadata.annotations.first.computeConstantValue(),
          );
          final buildStep = _FakeBuildStep(resolver, inputId);
          final output = await const KeyedFormGenerator()
              .generateForAnnotatedElement(
                libraryElement,
                annotation,
                buildStep,
              );

          expect(output, contains('class WidgetSchema'));
          expect(output, contains('class GadgetSchema'));
        },
        inputId: inputId,
      );
    });

    test('a declaration with no ks.object(...) initializer yields the "no schema" comment', () async {
      final output = await _generate('''
import 'package:keyed_schema/keyed_schema.dart';

@keyedSchema
final notASchema = 42;
''', 'notASchema');

      expect(output, contains('// No valid schema definition found'));
    });
  });
}
