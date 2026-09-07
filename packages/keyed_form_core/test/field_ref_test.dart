import 'package:keyed_form_core/keyed_form_core.dart';
import 'package:keyed_lens/keyed_lens.dart' show Prism;
import 'package:test/test.dart';

class Addr {
  const Addr(this.city);
  final String city;
  Addr copyWith({String? city}) => Addr(city ?? this.city);
}

class Profile {
  const Profile(this.name, this.addr, {this.memo});
  final String name;
  final Addr addr;
  final String? memo;
  Profile copyWith({String? name, Addr? addr, String? memo}) =>
      Profile(name ?? this.name, addr ?? this.addr, memo: memo ?? this.memo);
}

class Rooms implements KeyedRow {
  const Rooms(this.clientId, this.label);
  @override
  final String clientId;
  final String label;
  Rooms copyWith({String? label}) => Rooms(clientId, label ?? this.label);
}

class Order {
  const Order(this.rooms);
  final List<Rooms> rooms;
  Order copyWith({List<Rooms>? rooms}) => Order(rooms ?? this.rooms);
}

sealed class Pay {
  const Pay();
}

class Cash extends Pay {
  const Cash(this.note);
  final String note;
  Cash copyWith({String? note}) => Cash(note ?? this.note);
}

class Card extends Pay {
  const Card(this.last4);
  final String last4;
}

// A generated-style wrapper: a DelegatingFieldRef subclass in a *different*
// library than keyed_form_core, exercising the public `inner` field.
final class AddrFieldRefs extends DelegatingFieldRef<Profile, Addr> {
  AddrFieldRefs(super.inner);

  FieldRef<Profile, String> get city => inner.then(
    StrictFieldRef<Addr, String>.of(
      key: FieldKey.name('city'),
      get: (a) => a.city,
      set: (a, v) => a.copyWith(city: v),
    ),
  );
}

final _profileAddr = StrictFieldRef<Profile, Addr>.of(
  key: FieldKey.name('addr'),
  get: (p) => p.addr,
  set: (p, v) => p.copyWith(addr: v),
);

void main() {
  const p = Profile('Ada', Addr('London'));

  test('StrictFieldRef.of builds and reads/writes', () {
    final name = StrictFieldRef<Profile, String>.of(
      key: FieldKey.name('name'),
      get: (x) => x.name,
      set: (x, v) => x.copyWith(name: v),
    );
    expect(name.get(p), 'Ada');
    expect(name.set(p, 'Bob').name, 'Bob');
    expect(name.key.toPath(), 'name');
  });

  test('DelegatingFieldRef subclass is a FieldRef and composes', () {
    final AddrFieldRefs w = AddrFieldRefs(_profileAddr);

    // usable where a FieldRef is expected
    final FieldRef<Profile, Addr> asRef = w;
    expect(asRef.getOrNull(p)?.city, 'London');

    // composes via inherited .then
    final FieldRef<Profile, String> composed = w.then(
      StrictFieldRef<Addr, String>.of(
        key: FieldKey.name('city'),
        get: (a) => a.city,
        set: (a, v) => a.copyWith(city: v),
      ),
    );
    expect(composed.getOrNull(p), 'London');
    expect(composed.set(p, 'Paris').addr.city, 'Paris');

    // leaf getter
    expect(w.city.getOrNull(p), 'London');
    expect(w.city.key.toPath(), 'addr.city');
  });

  test('.whenPresent() refines a nullable field', () {
    final memo = StrictFieldRef<Profile, String?>.of(
      key: FieldKey.name('memo'),
      get: (x) => x.memo,
      set: (x, v) => x.copyWith(memo: v),
    );
    final FieldRef<Profile, String> present = memo.whenPresent();
    expect(present.getOrNull(p), isNull); // memo is null
    expect(present.set(p, 'hi').memo, isNull); // no-op while null
  });

  test('.narrow() narrows a sum type via VariantRef', () {
    final pay = StrictFieldRef<(Pay,), Pay>.of(
      key: FieldKey.name('pay'),
      get: (r) => r.$1,
      set: (r, v) => (v,),
    );
    final VariantRef<Pay, Cash> cash = Prism<Pay, Cash>.type();
    final FieldRef<(Pay,), String> note = pay
        .narrow(cash)
        .then(
          StrictFieldRef<Cash, String>.of(
            key: FieldKey.name('note'),
            get: (c) => c.note,
            set: (c, v) => c.copyWith(note: v),
          ),
        );
    expect(note.getOrNull((const Cash('paid'),)), 'paid');
    expect(note.getOrNull((const Card('1234'),)), isNull);
  });

  test('.at() descends into a list row by id', () {
    final rooms = StrictFieldRef<Order, List<Rooms>>.of(
      key: FieldKey.name('rooms'),
      get: (o) => o.rooms,
      set: (o, v) => o.copyWith(rooms: v),
    );
    final label = rooms
        .at('r1', (r) => r.clientId == 'r1')
        .then(
          StrictFieldRef<Rooms, String>.of(
            key: FieldKey.name('label'),
            get: (r) => r.label,
            set: (r, v) => r.copyWith(label: v),
          ),
        );
    const o = Order([Rooms('r1', 'Suite'), Rooms('r2', 'Twin')]);
    expect(label.getOrNull(o), 'Suite');
    expect(label.set(o, 'Deluxe').rooms.first.label, 'Deluxe');
    expect(label.getOrNull(const Order([])), isNull);
  });
}
