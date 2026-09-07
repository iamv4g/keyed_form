# keyed_form_flutter examples

Each subfolder is a standalone, `flutter run`-able app (a workspace member).

| Example | What it shows |
| --- | --- |
| [`showcase/`](showcase) | sign in → push a full tour-builder form: every field type, a by-id list, cross-field rules, a live `KeyedFormMode` switch, server-error merging, dirty tracking + reset, a responsive master/detail layout, and two-phase scroll-to-first-error over a lazy `CustomScrollView` |

```bash
cd showcase
dart run build_runner build
flutter create .
flutter run -d chrome
```
