import 'package:dart_mappable/dart_mappable.dart';

part 'app_state.mapper.dart';

@MappableClass()
class AppState with AppStateMappable {
  final String appVersion;

  const AppState({
    this.appVersion = 'v?.?.?',
  });
}
