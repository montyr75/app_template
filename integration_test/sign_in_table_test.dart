import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/table/sign_in_scenarios.dart';
import '../test/support/table/table.dart';
import 'support/emulator_apps.dart';
import 'support/emulator_backend.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestFirebase();
    await clearEmulators();
  });

  for (final scenario in signInScenarios) {
    testWidgets(scenario.name, (tester) => runOnTable(scenario, EmulatorTableBackend()));
  }
}
