import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../base_path.dart';

/// The square KF ribbon mark, with gradient palettes for both page themes.
/// Decorative: the adjacent brand text supplies the accessible name.
class BrandMark extends StatelessComponent {
  const BrandMark({super.key});

  @override
  Component build(BuildContext context) {
    return span(
      styles: const Styles(raw: {'display': 'inline-flex', 'flex-shrink': '0'}),
      attributes: {'aria-hidden': 'true'},
      [
        img(
          src: '$siteBasePath/images/logo.svg',
          alt: '',
          width: 28,
          height: 28,
          styles: const Styles(raw: {'display': 'var(--dark-only)'}),
        ),
        img(
          src: '$siteBasePath/images/logo-light.svg',
          alt: '',
          width: 28,
          height: 28,
          styles: const Styles(raw: {'display': 'var(--light-only)'}),
        ),
      ],
    );
  }
}
