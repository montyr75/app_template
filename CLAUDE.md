# CLAUDE.md

**app_template** is the kernel every new Flutter app in `C:\Projects\www\Dart\_flutter\` starts from: the app, error,
logger, and theme services, auth with gating, the Firestore repo, routes, popups, the version display, and the agent
testing scaffolding, and `TapTarget`, the primitive every custom control is built on (ARCHITECTURE.md §9.1). It has
no features of its own and gets none: changes here are to the kernel, and they land in the
next app copied from it.

Read `../ARCHITECTURE.md` first: it is the architecture this repo embodies, section by section. `docs/testing.md` is
the testing guide and the key table.

## Commands

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after changing a @riverpod or @Mappable* source
dart analyze                                                # must be clean
flutter test                                                # unit, widget, and fake-backend harness tests
flutter run -d windows --dart-define=USE_EMULATOR=true      # a debug client on the emulators (start them first)
```

From PowerShell: `& tool\emulators\start.cmd`, `& tool\emulators\test.cmd` (the gate for rules, transactions, and
scenarios), `& tool\emulators\stop.cmd`. The format check is in `docs/testing.md`.

## Placeholders a new app replaces

- `lib/firebase_options.dart` and the `demo-app-template` project id (`.firebaserc`, `tool/emulators/*.cmd`,
  `lib/dev/dev_config.dart`): `flutterfire configure` and `firebase use`.
- `lib/features/app/services/theme/app_theme.dart`: the app's design tokens, bundled fonts under `assets/fonts/`.
- `firestore.rules`: deny-all until a feature writes.
- The package name `app_template`.
