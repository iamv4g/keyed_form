# Screen guide

```bash
dart run build_runner build   # generate the *.kfg.dart files
flutter run -d chrome         # or macos / windows / linux / a device
```

| Screen | File | Shows |
|---|---|---|
| Sign in | [`lib/login/login_screen.dart`](lib/login/login_screen.dart) | text fields, `onTouched` mode, async validation (`isValidating` / `isFailedValidation`) |
| Invoice | [`lib/invoice/invoice_screen.dart`](lib/invoice/invoice_screen.dart) | `markReadOnly` / `force: true`, a derived field (`addRelation`) |
| Packing list | [`lib/packing_list/packing_list_screen.dart`](lib/packing_list/packing_list_screen.dart) | `KeyedFieldList` bound directly to a list field |
| Itinerary | [`lib/itinerary/itinerary_screen.dart`](lib/itinerary/itinerary_screen.dart) | a schema nested two levels deep, with a discriminated union at the leaf |
| Rebuild lab | [`lib/rebuild_lab/rebuild_lab_screen.dart`](lib/rebuild_lab/rebuild_lab_screen.dart) | O(1) rebuilds, made visible: 24 fields, one rebuild counter each |
| Tour builder | [`lib/tour_builder/tour_builder_screen.dart`](lib/tour_builder/tour_builder_screen.dart) | everything together: a dynamic list, cross-field `.refine` rules, a live `KeyedFormMode` switch, server-error merging, dirty tracking, and two-phase scroll-to-first-error over a lazy `CustomScrollView` |

[`lib/fields.dart`](lib/fields.dart) and [`lib/widgets/demo_note.dart`](lib/widgets/demo_note.dart) are shared across screens; [`lib/home/home_screen.dart`](lib/home/home_screen.dart) is the list above, as an app.
