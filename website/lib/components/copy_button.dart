import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

@client
class CopyButton extends StatefulComponent {
  const CopyButton({
    required this.text,
    this.label = 'COPY',
    this.classes = 'copy-btn mono',
    super.key,
  });

  final String text;
  final String label;
  final String classes;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _copy() {
    if (kIsWeb) {
      web.window.navigator.clipboard.writeText(component.text);
      setState(() {
        _copied = true;
      });
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _copied = false;
          });
        }
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: component.classes,
      onClick: _copy,
      [
        .text(_copied ? 'COPIED!' : component.label),
      ],
    );
  }
}
