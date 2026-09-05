import 'dart:convert';

/// One step of a [FieldKey] path. Sealed so consumers that *analyze* keys —
/// most importantly a future FieldKey→Lens resolver for server patches —
/// can switch exhaustively over the two kinds instead of sniffing a
/// `List<Object>`.
sealed class Segment {
  const Segment();
}

/// A struct-field step (`days`, `name`).
final class NameSegment extends Segment {
  const NameSegment(this.name);

  final String name;

  @override
  bool operator ==(Object other) => other is NameSegment && other.name == name;

  @override
  int get hashCode => Object.hash(NameSegment, name);

  @override
  String toString() => name;
}

/// A row-id step into a by-id list. [id] must have value equality
/// (`==`/`hashCode`); ids modeled as extension types over String/int erase
/// to their representation here, so keys built from typed ids and keys
/// parsed from serialized paths still compare equal.
final class IdSegment extends Segment {
  const IdSegment(this.id);

  final Object id;

  @override
  bool operator ==(Object other) => other is IdSegment && other.id == id;

  @override
  int get hashCode => Object.hash(IdSegment, id);

  @override
  String toString() => id.toString();
}

/// Stable identity of a field inside an immutable aggregate.
///
/// A [FieldKey] is a value object — a sequence of [Segment]s. It is the
/// *identity* half of the engine: validation errors, dirty tracking,
/// focus/scroll targets, undo grouping, and server patches are all keyed by
/// [FieldKey], never by lens instances (lenses are executable objects
/// without structural equality).
///
/// Keys are composed by concatenation, mirroring lens composition:
/// `FieldKey.name('days') + FieldKey.id(dayId) + FieldKey.name('name')`
/// renders as `days.<dayId>.name`.
final class FieldKey {
  FieldKey(Iterable<Segment> segments) : segments = List.unmodifiable(segments);

  FieldKey.name(String name) : this([NameSegment(name)]);

  /// A row-id key segment. [id] must have value equality (`==`/`hashCode`).
  FieldKey.id(Object id) : this([IdSegment(id)]);

  static final FieldKey root = FieldKey(const []);
  static final FieldKey empty = root;

  final List<Segment> segments;

  FieldKey child(Segment segment) => FieldKey([...segments, segment]);

  FieldKey operator +(FieldKey other) =>
      FieldKey([...segments, ...other.segments]);

  bool get isRoot => segments.isEmpty;

  /// The ancestor key made of this key's first [depth] segments, clamped to
  /// `[0, length]`. `prefix(0)` is [root]; `prefix(n >= length)` is this key.
  ///
  /// Used to derive the subtree a write belongs to — e.g. `key.prefix(2)`
  /// turns `days.['d1'].groups.['g2'].name` into `days.['d1']`, the unit a
  /// per-day validator re-checks.
  FieldKey prefix(int depth) {
    if (depth <= 0) return root;
    if (depth >= segments.length) return this;
    return FieldKey(segments.take(depth));
  }

  /// Whether [other] addresses this field or a field nested under it —
  /// useful for invalidating a subtree of errors/dirty flags when a row is
  /// removed.
  bool contains(FieldKey other) {
    if (other.segments.length < segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (other.segments[i] != segments[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldKey || other.segments.length != segments.length) {
      return false;
    }
    for (var i = 0; i < segments.length; i++) {
      if (other.segments[i] != segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);

  /// Canonical, reversible serialization — the frozen wire format. The
  /// inverse of [parse]: `FieldKey.parse(k.toPath()) == k` for every key
  /// built from [String]/[int] ids.
  ///
  /// Dot-separated bracket style — every segment is separated by `.`, the
  /// first token has no leading separator, [root] is the empty string:
  ///
  /// - [NameSegment] → the name with the reserved set `% . [ ]`
  ///   percent-encoded (`%XX`, uppercase hex, UTF-8 bytes); unicode passes
  ///   through raw. An empty name throws [ArgumentError] (names are
  ///   programmer-defined identifiers and would collide with the separator
  ///   syntax).
  /// - [IdSegment] with an [int] id → `[42]` (canonical decimal: optional
  ///   `-`, no leading zeros, no `-0`).
  /// - [IdSegment] with a [String] id → `['…']`, escaping only `\`→`\\` and
  ///   `'`→`\'`; the empty string is legal (`['']`).
  ///
  /// Only [String] and [int] ids are supported; any other runtime id type
  /// throws [ArgumentError]. Extension types over String/int erase to their
  /// representation and are therefore supported implicitly.
  ///
  /// Examples: `days.['d1'].groups.['g2'].name`, `days.[3].note`,
  /// `['d1'].name` (id-first), `days.['a.b'].name` (dots inside quotes need
  /// no escaping), name `a.b` → `a%2Eb`.
  String toPath() => segments.map(_encodeSegment).join('.');

  /// Parses the canonical [toPath] wire format. Throws [FormatException] on
  /// malformed input (a data error — an unterminated bracket/quote, a
  /// non-canonical int, a raw reserved char in a name, an empty or attached
  /// segment, a bad `%` escape). Use [tryParse] to get null instead.
  static FieldKey parse(String path) {
    final key = tryParse(path);
    if (key == null) {
      throw FormatException('Not a valid FieldKey path', path);
    }
    return key;
  }

  /// Like [parse] but returns null instead of throwing on malformed input.
  static FieldKey? tryParse(String path) {
    if (path.isEmpty) return root;

    final segments = <Segment>[];
    var i = 0;
    final n = path.length;

    while (true) {
      if (i >= n) return null; // empty token (leading/trailing `.`, `a..b`)

      if (path.codeUnitAt(i) == _lbracket) {
        final end = _scanBracket(path, i, segments);
        if (end < 0) return null;
        i = end;
      } else {
        final start = i;
        while (i < n && path.codeUnitAt(i) != _dot) {
          final c = path.codeUnitAt(i);
          if (c == _lbracket || c == _rbracket) return null; // raw bracket
          i++;
        }
        if (i == start) return null; // empty name segment
        final name = _decodeName(path.substring(start, i));
        if (name == null) return null; // bad `%` escape
        segments.add(NameSegment(name));
      }

      if (i >= n) break;
      // A token must be followed by end-of-input or a separator; e.g. a `]`
      // directly followed by more text is an attached/dangling token.
      if (path.codeUnitAt(i) != _dot) return null;
      i++; // consume separator; loop then requires another token
    }

    return FieldKey(segments);
  }

  /// Debug-only, pretty, and **lossy** — a name and a same-text id both
  /// render bare (`days.d1.name`), so this cannot be parsed back. Use
  /// [toPath] for anything reversible (logs that need round-tripping,
  /// persisted payloads).
  @override
  String toString() => segments.join('.');
}

// --- Codec (encode + decode tables kept side by side) ------------------------

const int _dot = 0x2E; // .
const int _lbracket = 0x5B; // [
const int _rbracket = 0x5D; // ]
const int _percent = 0x25; // %
const int _quote = 0x27; // '
const int _backslash = 0x5C; // \

String _encodeSegment(Segment segment) => switch (segment) {
  NameSegment(:final name) =>
    name.isEmpty
        ? throw ArgumentError.value(
            name,
            'name',
            'FieldKey name segment must not be empty',
          )
        : _encodeName(name),
  IdSegment(:final id) => _encodeId(id),
};

String _encodeId(Object id) {
  // Order matters: an extension type over int erases to int, over String to
  // String, so these `is` checks accept typed ids transparently.
  if (id is int) return '[$id]'; // int.toString() is already canonical
  if (id is String) return "['${_escapeStringId(id)}']";
  throw ArgumentError.value(id, 'id', 'FieldKey id must be a String or int');
}

/// Percent-encodes the reserved set `% . [ ]` (uppercase hex over the char's
/// single ASCII byte); every other character — including all unicode — is
/// emitted verbatim.
String _encodeName(String name) {
  final out = StringBuffer();
  for (final rune in name.runes) {
    if (rune == _percent ||
        rune == _dot ||
        rune == _lbracket ||
        rune == _rbracket) {
      out.write('%');
      out.write(rune.toRadixString(16).toUpperCase().padLeft(2, '0'));
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

/// Inverse of [_encodeName]; null on a malformed `%` escape. Accumulates raw
/// bytes (unicode passes through as its own UTF-8 bytes, `%XX` decodes to one
/// byte) then UTF-8 decodes, so it round-trips regardless of encoding path.
String? _decodeName(String token) {
  final raw = utf8.encode(token);
  final bytes = <int>[];
  for (var i = 0; i < raw.length; i++) {
    if (raw[i] == _percent) {
      if (i + 2 >= raw.length) return null;
      final hi = _hexDigit(raw[i + 1]);
      final lo = _hexDigit(raw[i + 2]);
      if (hi < 0 || lo < 0) return null;
      bytes.add(hi * 16 + lo);
      i += 2;
    } else {
      bytes.add(raw[i]);
    }
  }
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return null;
  }
}

String _escapeStringId(String id) {
  final out = StringBuffer();
  for (final unit in id.codeUnits) {
    if (unit == _backslash || unit == _quote) out.write(r'\');
    out.writeCharCode(unit);
  }
  return out.toString();
}

/// Scans one bracket token starting at [open] (a `[`), appends the decoded
/// [IdSegment] to [into], and returns the index just past the closing `]`, or
/// -1 if malformed.
int _scanBracket(String path, int open, List<Segment> into) {
  final n = path.length;
  var i = open + 1;
  if (i >= n) return -1; // unterminated `[`

  if (path.codeUnitAt(i) == _quote) {
    // String id: read to the unescaped closing quote, then require `]`.
    i++;
    final value = StringBuffer();
    var closed = false;
    while (i < n) {
      final c = path.codeUnitAt(i);
      if (c == _backslash) {
        if (i + 1 >= n) return -1;
        final next = path.codeUnitAt(i + 1);
        if (next != _quote && next != _backslash) return -1; // bad escape
        value.writeCharCode(next);
        i += 2;
      } else if (c == _quote) {
        closed = true;
        i++;
        break;
      } else {
        value.writeCharCode(c);
        i++;
      }
    }
    if (!closed) return -1; // unterminated quote
    if (i >= n || path.codeUnitAt(i) != _rbracket) return -1;
    into.add(IdSegment(value.toString()));
    return i + 1;
  }

  // Int id: read to `]`, accept only a canonical decimal.
  final start = i;
  while (i < n && path.codeUnitAt(i) != _rbracket) {
    i++;
  }
  if (i >= n) return -1; // unterminated (no `]`)
  final content = path.substring(start, i);
  final parsed = int.tryParse(content);
  // Re-encoding must match verbatim, rejecting empty/`042`/`-0`/`42x`.
  if (parsed == null || parsed.toString() != content) return -1;
  into.add(IdSegment(parsed));
  return i + 1;
}

/// Value of an ASCII hex digit byte, or -1 if it is not one. Accepts both
/// cases on decode though [_encodeName] always emits uppercase.
int _hexDigit(int byte) {
  if (byte >= 0x30 && byte <= 0x39) return byte - 0x30; // 0-9
  if (byte >= 0x41 && byte <= 0x46) return byte - 0x41 + 10; // A-F
  if (byte >= 0x61 && byte <= 0x66) return byte - 0x61 + 10; // a-f
  return -1;
}
