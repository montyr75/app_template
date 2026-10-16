import 'package:flutter_test/flutter_test.dart';

import '../support/table/fake_backend.dart';
import '../support/table/sign_in_scenarios.dart';
import '../support/table/table.dart';

void main() {
  for (final scenario in signInScenarios) {
    test(
      scenario.name,
      () => runOnTable(scenario, FakeTableBackend()),
      skip: scenario.emulatorOnly ? r'emulator only: tool\emulators\test.cmd runs it' : null,
    );
  }
}
