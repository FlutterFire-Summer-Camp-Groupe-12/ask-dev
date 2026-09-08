import 'dart:async';

import 'package:askdev/core/utils/app_logger.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/myapp.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    final logger = AppLogger.init();
    logger.installGlobalHandlers();
    logger.info('Bootstrap', 'App starting');
    configureDependencies();
    runApp(const MyApp());
  }, (error, stack) {
    AppLogger.instance.fatal(
      'UncaughtZone',
      'Unhandled zone error',
      error: error,
      stackTrace: stack,
    );
  });
}