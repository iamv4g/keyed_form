import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../package_versions.dart';

const _packages = [
  (
    name: 'keyed_lens',
    desc: 'Pure Dart, 0 dependencies. Typed update primitives for nested immutable values.',
  ),
  (
    name: 'keyed_form_core',
    desc:
        "Depends on keyed_lens. The form tier's shared vocabulary: FieldRef, StrictFieldRef, FieldErrors, @keyedSchema.",
  ),
  (
    name: 'keyed_form_schema',
    desc: 'Depends on keyed_form_core. The declarative schema & validation DSL (ks.*). Pure Dart.',
  ),
  (
    name: 'keyed_form_gen',
    desc: 'Dev-time build_runner codegen: turns a schema into an immutable model, typed field refs and a validator.',
  ),
  (name: 'keyed_form', desc: 'The pure-Dart state controller (KeyedFormController) with scoped listener bindings.'),
  (
    name: 'keyed_form_flutter',
    desc: 'The Flutter binding layer: KeyedForm, KeyedFormField, KeyedFieldList, KeyedTextBinding.',
  ),
];

class PackageTopology extends StatelessComponent {
  const PackageTopology({super.key});

  @override
  Component build(BuildContext context) {
    final versions = PackageVersions.of(context);
    return div(classes: 'topology-grid mono', [
      for (final pkg in _packages)
        a(
          classes: 'blueprint-box topology-card',
          href: 'https://pub.dev/packages/${pkg.name}',
          target: Target.blank,
          [
            div(classes: 'topology-head', [
              span(classes: 'topology-title', [.text(pkg.name)]),
              if (versions[pkg.name] case final version?) span(classes: 'topology-version', [.text('v$version')]),
            ]),
            div(classes: 'topology-desc', [.text(pkg.desc)]),
          ],
        ),
    ]);
  }
}
