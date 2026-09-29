import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Inline SVG icons for the navbar and footer. All draw in `currentColor`,
/// so they follow the surrounding link's color (and its hover state) in
/// both themes.
abstract final class SiteIcons {
  /// The Dart logo — stands for pub.dev, where every package is published.
  static Component dart({int size = 18}) => svg(
    viewBox: '0 0 500 500',
    width: size.px,
    height: size.px,
    attributes: {'fill': 'currentColor', 'aria-hidden': 'true'},
    [
      path(
        d: 'M361.48,76.85c2.8,0,5.56,0.03,8.29,0.16c-25.24-25.24-60.56-60.56-60.56-60.56C301.74,8.94,286.18,0,273.03,0c-11.31,0-22.41,2.26-29.6,6.58L103.6,76.85H361.48zM361.48,94.2H104.82l317.69,317.69l77.48-0.71l0-203.95L396.05,103.29C386.33,95.59,377.06,94.2,361.48,94.2zM94.2,364.21c0,24.93,2.89,28.85,13.92,39.93l-0.01,0.01L203.95,500l207.24,0l-0.71-75.61L94.2,108.11V364.21zM76.85,364.21l0-261.42L6.58,250C3.76,255.98,0,266.38,0,273.03c0,14.36,6.32,29.06,16.45,39.47l60.57,60.58C76.91,370.34,76.85,367.41,76.85,364.21z',
        [],
      ),
    ],
  );

  /// The GitHub mark.
  static Component github({int size = 18}) => svg(
    viewBox: '0 0 16 16',
    width: size.px,
    height: size.px,
    attributes: {'fill': 'currentColor', 'aria-hidden': 'true'},
    [
      path(
        d: 'M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z',
        [],
      ),
    ],
  );

  static Component sun({int size = 18, String? classes}) => svg(
    classes: classes,
    viewBox: '0 0 24 24',
    width: size.px,
    height: size.px,
    attributes: {
      'fill': 'none',
      'stroke': 'currentColor',
      'stroke-width': '2',
      'stroke-linecap': 'round',
      'aria-hidden': 'true',
    },
    [
      circle(cx: '12', cy: '12', r: '4', []),
      path(
        d: 'M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41',
        [],
      ),
    ],
  );

  static Component moon({int size = 18, String? classes}) => svg(
    classes: classes,
    viewBox: '0 0 24 24',
    width: size.px,
    height: size.px,
    attributes: {
      'fill': 'none',
      'stroke': 'currentColor',
      'stroke-width': '2',
      'stroke-linecap': 'round',
      'stroke-linejoin': 'round',
      'aria-hidden': 'true',
    },
    [
      path(d: 'M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z', []),
    ],
  );
}
