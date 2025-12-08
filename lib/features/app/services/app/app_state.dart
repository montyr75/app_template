class AppState {
  final String appVersion;

  const AppState({
    this.appVersion = 'v?.?.?',
  });

  AppState copyWith({
    String? appVersion,
  }) {
    return AppState(
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
