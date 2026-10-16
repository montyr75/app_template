import 'package:app_template/dev/dev_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android outside the web reaches the host through 10.0.2.2', () {
    expect(resolveEmulatorHost(override: '', platform: TargetPlatform.android, isWeb: false), '10.0.2.2');
  });

  test('Android on the web uses loopback', () {
    expect(resolveEmulatorHost(override: '', platform: TargetPlatform.android, isWeb: true), '127.0.0.1');
  });

  test('Windows uses loopback', () {
    expect(resolveEmulatorHost(override: '', platform: TargetPlatform.windows, isWeb: false), '127.0.0.1');
  });

  test('an override wins', () {
    expect(
      resolveEmulatorHost(override: '192.168.1.20', platform: TargetPlatform.android, isWeb: false),
      '192.168.1.20',
    );
  });

  test('useEmulator is off in a plain flutter test', () {
    expect(useEmulator, isFalse);
  });
}
