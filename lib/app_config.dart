import 'package:flutter/foundation.dart';

import 'features/app/services/logger_service.dart';

// app info
const appName = "app_template";
const debugMode = !kReleaseMode;

// create logger
final log = LoggerService(appName: appName, debugMode: debugMode);
