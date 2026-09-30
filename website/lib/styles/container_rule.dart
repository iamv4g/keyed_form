import 'package:jaspr/dom.dart';

/// Renders a `@container` rule; jaspr's `css` has builders for `@media` and
/// `@supports` but not this one.
class ContainerStyleRule implements StyleRule {
  const ContainerStyleRule(this.condition, this.styles);

  /// For example `(min-width: 48rem)`.
  final String condition;
  final List<StyleRule> styles;

  @override
  String toCss([String indent = '']) {
    return '$indent@container $condition { ${styles.map((r) => '${r.toCss()} ').join()}}';
  }
}
