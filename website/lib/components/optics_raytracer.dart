import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class OpticsRaytracer extends StatefulComponent {
  const OpticsRaytracer({super.key});

  @override
  State<OpticsRaytracer> createState() => _OpticsRaytracerState();
}

class _OpticsRaytracerState extends State<OpticsRaytracer> {
  String _selectedId = 'target';

  static const _nodes = {
    'root': (
      path: 'TourSchema',
      type: 'TourSchema',
      desc: 'Root Data Schema',
    ),
    'lens1': (
      path: 'TourFields.stop(ref)',
      type: 'AffineLens<TourSchema, StopSchema>',
      desc: 'Affine List Element Lens',
    ),
    'lens2': (
      path: 'TourFields.stop(ref).nights',
      type: 'Lens<StopSchema, int>',
      desc: 'Direct Property Focus',
    ),
    'target': (
      path: 'TourFields.stop(ref).nights',
      type: 'FieldRef<TourSchema, int>',
      desc: 'Compile-Time Typed Reference',
    ),
  };

  void _selectNode(String id) {
    setState(() {
      _selectedId = id;
    });
  }

  @override
  Component build(BuildContext context) {
    final active = _nodes[_selectedId] ?? _nodes['target']!;

    return div(id: 'optics', classes: 'blueprint-box workbench', [
      div(classes: 'workbench-header', [
        span(classes: 'workbench-title mono', [
          .text('// LIVE RESOLUTION ENGINE'),
        ]),
        span(classes: 'workbench-subtitle mono', [
          .text('INTERACTIVE LENS RAYTRACER'),
        ]),
      ]),
      div(classes: 'optics-canvas', [
        svg(
          viewBox: '0 0 800 160',
          attributes: {
            'role': 'img',
            'aria-label': 'Field reference optical resolution raytracer',
          },
          [
            Component.element(
              tag: 'defs',
              children: [
                Component.element(
                  tag: 'linearGradient',
                  attributes: {
                    'id': 'laserBeam',
                    'x1': '0%',
                    'y1': '0%',
                    'x2': '100%',
                    'y2': '0%',
                  },
                  children: [
                    Component.element(
                      tag: 'stop',
                      attributes: {
                        'offset': '0%',
                        'stop-color': 'var(--cyan)',
                        'stop-opacity': '0.2',
                      },
                    ),
                    Component.element(
                      tag: 'stop',
                      attributes: {
                        'offset': '50%',
                        'stop-color': 'var(--cyan)',
                        'stop-opacity': '0.9',
                      },
                    ),
                    Component.element(
                      tag: 'stop',
                      attributes: {
                        'offset': '100%',
                        'stop-color': 'var(--amber)',
                        'stop-opacity': '0.9',
                      },
                    ),
                  ],
                ),
              ],
            ),
            line(
              x1: '40',
              y1: '80',
              x2: '760',
              y2: '80',
              attributes: {
                'stroke': 'var(--border-bright)',
                'stroke-dasharray': '4 4',
              },
              [],
            ),
            line(
              x1: '40',
              y1: '80',
              x2: '760',
              y2: '80',
              attributes: {
                'stroke': 'url(#laserBeam)',
                'stroke-width': '2',
              },
              [],
            ),
            // Root Node
            Component.element(
              tag: 'g',
              classes: 'node-btn${_selectedId == 'root' ? ' active' : ''}',
              events: {'click': (_) => _selectNode('root')},
              children: [
                circle(
                  cx: '80',
                  cy: '80',
                  r: '14',
                  attributes: {
                    'fill': 'var(--surface-elevated)',
                    'stroke': 'var(--border-bright)',
                    'stroke-width': '2',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '80',
                    'y': '84',
                    'text-anchor': 'middle',
                    'font-size': '10',
                    'fill': 'var(--ink)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('Ø')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '80',
                    'y': '115',
                    'text-anchor': 'middle',
                    'font-size': '11',
                    'fill': 'var(--ink-muted)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('TourSchema')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '80',
                    'y': '132',
                    'text-anchor': 'middle',
                    'font-size': '9',
                    'fill': 'var(--ink-faint)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('root')],
                ),
              ],
            ),
            // Lens 1: Affine Stop Lens
            Component.element(
              tag: 'g',
              classes: 'node-btn${_selectedId == 'lens1' ? ' active' : ''}',
              events: {'click': (_) => _selectNode('lens1')},
              children: [
                ellipse(
                  cx: '320',
                  cy: '80',
                  rx: '12',
                  ry: '32',
                  attributes: {
                    'fill': 'var(--surface-elevated)',
                    'stroke': 'var(--cyan)',
                    'stroke-width': '2',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '320',
                    'y': '85',
                    'text-anchor': 'middle',
                    'font-size': '11',
                    'fill': 'var(--cyan)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('λ')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '320',
                    'y': '128',
                    'text-anchor': 'middle',
                    'font-size': '12',
                    'fill': 'var(--cyan)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('.stop(ref)')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '320',
                    'y': '144',
                    'text-anchor': 'middle',
                    'font-size': '9',
                    'fill': 'var(--ink-muted)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('UUID keyed')],
                ),
              ],
            ),
            // Lens 2: Property Lens
            Component.element(
              tag: 'g',
              classes: 'node-btn${_selectedId == 'lens2' ? ' active' : ''}',
              events: {'click': (_) => _selectNode('lens2')},
              children: [
                ellipse(
                  cx: '520',
                  cy: '80',
                  rx: '10',
                  ry: '26',
                  attributes: {
                    'fill': 'var(--surface-elevated)',
                    'stroke': 'var(--cyan)',
                    'stroke-width': '2',
                  },
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '520',
                    'y': '85',
                    'text-anchor': 'middle',
                    'font-size': '11',
                    'fill': 'var(--cyan)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('π')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '520',
                    'y': '125',
                    'text-anchor': 'middle',
                    'font-size': '12',
                    'fill': 'var(--cyan)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('.nights')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '520',
                    'y': '141',
                    'text-anchor': 'middle',
                    'font-size': '9',
                    'fill': 'var(--ink-muted)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('property')],
                ),
              ],
            ),
            // Target Focus Node
            Component.element(
              tag: 'g',
              classes: 'node-btn${_selectedId == 'target' ? ' active' : ''}',
              events: {'click': (_) => _selectNode('target')},
              children: [
                circle(
                  cx: '720',
                  cy: '80',
                  r: '16',
                  attributes: {
                    'fill': 'var(--amber-glow)',
                    'stroke': 'var(--amber)',
                    'stroke-width': '2',
                  },
                  [],
                ),
                circle(
                  cx: '720',
                  cy: '80',
                  r: '5',
                  attributes: {'fill': 'var(--amber)'},
                  [],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '720',
                    'y': '115',
                    'text-anchor': 'middle',
                    'font-size': '12',
                    'fill': 'var(--amber)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('int')],
                ),
                Component.element(
                  tag: 'text',
                  attributes: {
                    'x': '720',
                    'y': '132',
                    'text-anchor': 'middle',
                    'font-size': '9',
                    'fill': 'var(--amber)',
                    'font-family': 'JetBrains Mono',
                  },
                  children: [.text('FieldRef')],
                ),
              ],
            ),
          ],
        ),
      ]),
      div(classes: 'beam-status mono', [
        div([
          span(classes: 'beam-label', [.text('COORDINATE:')]),
          span(id: 'beam-path', classes: 'beam-path', [.text(active.path)]),
        ]),
        div([
          span(classes: 'beam-label', [.text('SIGNATURE:')]),
          span(id: 'beam-type', classes: 'beam-type', [.text(active.type)]),
        ]),
        div(classes: 'beam-verified', [
          .text('[ COMPILE-TIME VERIFIED ]'),
        ]),
      ]),
    ]);
  }
}
