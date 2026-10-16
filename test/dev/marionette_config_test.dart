import 'package:app_template/dev/marionette_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marionette_logging/marionette_logging.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('logs reach get_logs', () {
    final config = buildMarionetteConfig();

    expect(config.logCollector, isA<LoggingLogCollector>());
  });

  testWidgets('material_ui controls are interactive and plain text is not', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Go')),
              const Text('Plain'),
              TextField(controller: TextEditingController(text: 'typed')),
            ],
          ),
        ),
      ),
    );

    final config = buildMarionetteConfig();
    final button = tester.element(find.byType(FilledButton));
    final text = tester.element(find.text('Plain'));
    final field = tester.element(find.byType(TextField));

    expect(config.isInteractiveElement!(button), isTrue);
    expect(config.shouldStopTraversalAtElement!(button), isTrue);
    expect(config.isInteractiveElement!(text), isFalse);
    expect(config.extractText!(field), 'typed');
    expect(config.extractText!(text), isNull);
  });
}
