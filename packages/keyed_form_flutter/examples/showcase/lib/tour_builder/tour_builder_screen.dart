import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:keyed_form_flutter/keyed_form_flutter.dart';

import 'state_inspector.dart';
import 'tour_form.dart';
import 'tour_schema.dart';

class TourBuilderScreen extends StatefulWidget {
  const TourBuilderScreen({this.email, super.key});

  /// Shown in the app bar — the value the login form collected.
  final String? email;

  @override
  State<TourBuilderScreen> createState() => _TourBuilderScreenState();
}

class _TourBuilderScreenState extends State<TourBuilderScreen> {
  final registry = KeyedFieldRegistry();
  final _scroll = ScrollController();

  KeyedFormMode _mode = KeyedFormMode.onTouched;
  late KeyedFormController<TourSchema> _form = _makeController(
    TourSchema.create(
      title: 'Kyoto in autumn',
      stops: [
        StopSchema.create(city: 'Kyoto', nights: 3),
        StopSchema.create(city: 'Nara', nights: 1),
      ],
    ),
  );

  // Section keys: index 0 = the details card, 1..N = one per stop. Each
  // section's sliver exposes `precedingScrollExtent` for the coarse jump.
  final _detailsSectionKey = GlobalKey();
  final _stopSectionKeys = <String, GlobalKey>{};
  List<String> _stopIds = const [];

  KeyedFormController<TourSchema> _makeController(TourSchema seed) =>
      KeyedFormController<TourSchema>(
        initialValue: seed,
        mode: _mode,
        resolver: (draft, _) => TourSchema.validateData(draft),
      );

  @override
  void initState() {
    super.initState();
    _stopIds = _currentStopIds();
    _form.addListener(_onFormChange);
  }

  @override
  void dispose() {
    _form
      ..removeListener(_onFormChange)
      ..dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<String> _currentStopIds() => [
    for (final stop in _form.value.stops) stop.clientId,
  ];

  void _onFormChange() {
    final ids = _currentStopIds();
    if (!_sameOrder(ids, _stopIds)) {
      setState(() {
        _stopIds = ids;
        _stopSectionKeys.removeWhere((id, _) => !ids.contains(id));
      });
    }
  }

  // KeyedFormMode is final on the controller, so switching it rebuilds the
  // controller, re-baselined to the current draft.
  void _setMode(KeyedFormMode mode) {
    if (mode == _mode) return;
    final draft = _form.value;
    _form
      ..removeListener(_onFormChange)
      ..dispose();
    setState(() {
      _mode = mode;
      _form = _makeController(draft)..addListener(_onFormChange);
    });
  }

  KeyedFormList<TourSchema, StopSchema> get _stops =>
      _form.field(TourFields.stops).list();

  Future<void> _save() async {
    if (_form.validate()) {
      final tour = _form.value;
      final nights = tour.stops.fold<int>(0, (sum, s) => sum + s.nights);
      _toast(
        'Saved "${tour.title}" — ${tour.stops.length} stops, $nights nights',
      );
      return;
    }
    await _revealFirstError();
  }

  void _reset() {
    _form.reset();
    _toast('Reverted to the last saved tour');
  }

  void _simulateServerError() {
    // The shape a JSON error body usually arrives in — `FieldKey` wire paths.
    _form.setServerErrorPaths(const {
      'title': 'A tour with this name already exists',
    });
    _toast('Server rejected the tour name');
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));

  // ── scroll-to-first-error (two phase: jump the section, then reveal) ─────

  Future<void> _revealFirstError() async {
    final keys = _form.visibleErrorKeys.toList();
    if (keys.isEmpty) return;
    await _jumpToSection(_sectionForKey(keys.first));
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    registry.revealFirst(_form.visibleErrorKeys, alignment: 0.5);
  }

  int _sectionForKey(FieldKey key) {
    if (TourFields.stops.key.contains(key) && key.segments.length >= 2) {
      final segment = key.segments[1];
      if (segment is IdSegment) {
        final index = _stopIds.indexWhere((id) => id == segment.id);
        if (index >= 0) return index + 1;
      }
      return _stopIds.isEmpty ? 0 : 1;
    }
    return 0;
  }

  GlobalKey _sectionKey(int index) => index == 0
      ? _detailsSectionKey
      : _stopSectionKeys.putIfAbsent(_stopIds[index - 1], GlobalKey.new);

  int get _sectionCount => 1 + _stopIds.length;

  double? _sectionOffset(int index) {
    if (index <= 0) return 0;
    if (index >= _sectionCount) return null;
    final render = _sectionKey(index).currentContext?.findRenderObject();
    if (render is RenderSliver && render.geometry != null) {
      return render.constraints.precedingScrollExtent;
    }
    return null;
  }

  double? _measuredOffsetAfter(int index) {
    for (var i = index + 1; i < _sectionCount; i++) {
      final offset = _sectionOffset(i);
      if (offset != null) return offset;
    }
    return null;
  }

  Future<void> _jumpToSection(int index) async {
    for (var attempt = 0; attempt < 8; attempt++) {
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      final offset = _sectionOffset(index);
      if (offset != null) {
        final target = offset.clamp(0.0, position.maxScrollExtent);
        if ((position.pixels - target).abs() <= 2) return;
        if (attempt == 0) {
          await _scroll.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else {
          position.jumpTo(target);
          await WidgetsBinding.instance.endOfFrame;
        }
        continue;
      }
      final below = _measuredOffsetAfter(index);
      final double frontier;
      if (below != null) {
        frontier = (below - position.viewportDimension).clamp(
          0.0,
          position.maxScrollExtent,
        );
      } else {
        frontier = math.min(
          position.pixels + position.viewportDimension,
          position.maxScrollExtent,
        );
      }
      if ((frontier - position.pixels).abs() <= 2) return;
      position.jumpTo(frontier);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  // ── build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return KeyedFormScope<TourSchema>(
      controller: _form,
      registry: registry,
      child: Scaffold(
        appBar: AppBar(
          title: widget.email == null
              ? const Text('Tour builder')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tour builder'),
                    Text(
                      'signed in as ${widget.email}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
          actions: [
            const DirtyBadge(),
            PopupMenuButton<KeyedFormMode>(
              tooltip: 'Error visibility mode',
              initialValue: _mode,
              onSelected: _setMode,
              icon: const Icon(Icons.visibility_outlined),
              itemBuilder: (context) => [
                for (final mode in KeyedFormMode.values)
                  PopupMenuItem(value: mode, child: Text('mode: ${mode.name}')),
              ],
            ),
            IconButton(
              tooltip: 'Simulate a server error',
              onPressed: _simulateServerError,
              icon: const Icon(Icons.cloud_off_outlined),
            ),
            IconButton(
              tooltip: 'Reset',
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: const Text('Save'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final body = TourFormBody(
              scroll: _scroll,
              stopIds: _stopIds,
              sectionKey: _sectionKey,
              stops: () => _stops,
            );
            if (constraints.maxWidth < 900) return body;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: body),
                const VerticalDivider(width: 1),
                const SizedBox(width: 360, child: StateInspector()),
              ],
            );
          },
        ),
      ),
    );
  }
}

bool _sameOrder(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
