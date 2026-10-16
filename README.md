# app_template

The kernel every new Flutter app in this folder starts from. The architecture it embodies is
`../ARCHITECTURE.md`; the testing setup is `docs/testing.md`.

To start an app: copy this folder, rename the package (`pubspec.yaml`, the `package:app_template/` imports under
`test/` and `integration_test/`, the platform folders), run `flutterfire configure` for its Firebase project (which
overwrites `lib/firebase_options.dart` and extends `firebase.json`), `firebase use` the project, put the real project id
in `tool/emulators/*.cmd` and `lib/dev/dev_config.dart`, and replace the placeholder theme in
`lib/features/app/services/theme/app_theme.dart` with the app's design tokens.
