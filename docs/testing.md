# Testing the app

The guide for an agent (or the owner) arriving cold: what each test layer is, how to run it, and how to seat several
clients on the Firebase Local Emulator Suite and drive them by key. Nothing here talks to a live Firebase project: unit
and widget tests use fakes, and integration tests use the emulators only. The full paradigm, with the layers this
kernel does not build yet (rules suite, invariants, soak), is `C:\Projects\www\Dart\_flutter\kingpin_clash\docs\testing.md`.

Run `.cmd` scripts from PowerShell (`& tool\emulators\test.cmd`). Git Bash rewrites a leading `/c` argument into `C:/`,
which breaks the `cmd /c` calls inside them.

## The layers

| Layer | What it is | Status | Run it with |
|---|---|---|---|
| Pure logic | Decision functions factored out of services (`authRedirect`, `reduceUserChange`) and, as the app grows, its rules engines over a seeded `Random` | built for the kernel | `flutter test` |
| Widget tests | Each screen at its design surface, asserting copy, states, keys, and no overflow | none yet | `flutter test` |
| Table harness, fake backend | `TestTable` (`test/support/table/table.dart`) seats N users, each a `ProviderContainer` with its own `MockFirebaseAuth` over one shared `SerialFakeFirestore`, driving the real services | skeleton: seats sign in (`sign_in_scenarios.dart`) | `flutter test` (`test/table/`) |
| Table harness, emulator backend | The same scenario lists with one named `FirebaseApp` per seat, signed in as `p1@app-template.test`, `p2@app-template.test`, and so on, so transactions contend for real and the security rules apply; `emulatorOnly` scenarios run only here | skeleton | `tool\emulators\test.cmd` (`integration_test/*_table_test.dart`) |
| Emulator smoke test | Two named apps sign in with distinct uids, and a write the rules forbid throws `permission-denied` | built | `tool\emulators\test.cmd integration_test\emulator_smoke_test.dart` |
| Rules suite | One ALLOW or DENY case per `firestore.rules` branch, run as signed-in seats; each ALLOW writes exactly what the app writes, each DENY is an attack | not yet: the rules are deny-all | `tool\emulators\test.cmd` |
| Invariant checker | A pure `checkInvariants(...)` over the persisted models returning named violations; the harness asserts it after every step and debug builds log it | not yet: comes with the models | everywhere |
| Autopilot, soak | Debug-only seats that play by themselves while an observer checks invariants | not yet | `tool\emulators\soak.cmd` |
| Agent UI driving | The Marionette binding in debug builds (`lib/dev/marionette_config.dart`), driven through the `marionette` CLI or MCP | built | below |

**A failing scenario, rules case, or soak is a defect in the app's services.** Fix the service and pin the fix with a
unit test. Never loosen the scenario.

**The gate.** Run `tool\emulators\test.cmd` whenever `firestore.rules`, a transaction, or a harness scenario changes, and
at the end of every milestone, alongside these:

```powershell
dart analyze                                     # clean
dart format --output=none --set-exit-if-changed (Get-ChildItem lib,test,integration_test -Recurse -Filter *.dart | Where-Object Name -NotMatch '\.g\.dart$|\.mapper\.dart$|^firebase_options\.dart$' | ForEach-Object FullName)
flutter test                                     # green
& tool\emulators\test.cmd                        # green; Get-NetTCPConnection -LocalPort 8080 -State Listen prints nothing afterwards
```

## Providers are the seam

The harness depends on every Firebase client coming through an overridable provider:

- `firestoreProvider` (`lib/db/repos/db_repo.dart`)
- `firebaseAuthProvider` and `authStateChangesProvider` (`lib/features/auth/repos/auth_repo.dart`)

Never call `FirebaseFirestore.instance` or `FirebaseAuth.instance` anywhere else (`main.dart` applies Firestore
settings through the instance once, before anything else uses it). Anything process-global, such as a
`SharedPreferences` key, must be scoped per account, or seats in one process overwrite each other.

## Emulators

- `tool\emulators\start.cmd` starts Auth on 9099, Firestore on 8080, and the Emulator UI on <http://127.0.0.1:4000>.
  It runs the project `demo-app-template` in single-project mode, which the emulators accept without credentials;
  once `flutterfire configure` and `firebase use` name the real project, change the id in the three scripts and in
  `lib/dev/dev_config.dart`. Stop it with Ctrl+C.
- `tool\emulators\stop.cmd` stops the java and node processes listening on the emulator ports, which `emulators:exec`
  can leave behind on Windows.
- `tool\emulators\test.cmd [paths...]` runs the integration tests on Windows desktop against fresh emulators, one
  `flutter test <file> -d windows` per file, then runs `stop.cmd`.
- A debug client on the emulators: start them, then `flutter run -d windows --dart-define=USE_EMULATOR=true`. The
  define is honored only under `kDebugMode` (`lib/dev/dev_config.dart`); a physical device adds
  `--dart-define=EMULATOR_HOST=<the PC's LAN address>`.

## Driving clients with Marionette

Debug builds start the Marionette binding (`main.dart`), configured in `lib/dev/marionette_config.dart`. The
`marionette_flutter` and `marionette_logging` packages move together with the global `marionette_cli` and
`marionette_mcp` tools at the same minor version. Run the app, note the VM service URI, connect, then
`get-interactive-elements`, `tap`, `enter-text`, `screenshot`, and `get-logs` (the app logs through
`package:logging`, so every `log.*` line is collected). Because the app imports `material_ui`, its Material controls
are registered in the config by type; register every custom interactive widget there too and return its label from
`extractText`.

### Keys

**Keys are the contract between the app and the agent.** Every interactive control carries a `ValueKey<String>` named
`<screen>_<control>` in lower camel case; repeated items carry an id suffix (`catalogue_unit_<unitId>`). Use
`Semantics(identifier: …)` only where a key cannot be placed. Every task that builds a screen adds its keys here:

| Screen | Keys |
|---|---|
| Login | `login_emailField`, `login_passwordField`, `login_passwordVisibilityButton`, `login_signInButton`, `login_registerLink` |
| Register | `register_emailField`, `register_passwordField`, `register_confirmPasswordField`, `register_registerButton`, `register_signInLink` |
| Home | `home_settingsButton`, `home_signOutButton` |
| Settings | `settings_themeModeSegments` |
| Not found | `notFound_homeButton` |

## Adding a scenario

Write it once as a `TableScenario` in a `*_scenarios.dart` list under `test/support/table/`, run the list from a
`test/table/*_table_test.dart` on `FakeTableBackend` and from an `integration_test/*_table_test.dart` on
`EmulatorTableBackend`, and mark it `emulatorOnly` when it needs real contention or the rules. Give `TestSeat` a getter
per service as services arrive, and end every scenario with the invariant check once the models exist.
