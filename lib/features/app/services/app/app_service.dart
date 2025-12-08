import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/error_service.dart';
import 'app_state.dart';

part 'app_service.g.dart';

@Riverpod(keepAlive: true)
class AppService extends _$AppService {
  @override
  AppState build() {
    ref.listen(packageInfoProvider, (previous, next) {
      next.when(
        data: (info) => state = state.copyWith(appVersion: 'v${info.version}'),
        error: (err, stack) {
          ref
              .read(errorServiceProvider.notifier)
              .onError(
            provider: appServiceProvider,
            error: AppError(message: "Error loading app version."),
          );
        },
        // No action needed on loading, the state will just not have the version yet.
        loading: () {},
      );
    });

    return const AppState();
  }
}

@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) => PackageInfo.fromPlatform();
