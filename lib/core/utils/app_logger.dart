import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

enum AppLogLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal,
}

extension on AppLogLevel {
  Level toLevel() {
    switch (this) {
      case AppLogLevel.trace:
        return Level.trace;
      case AppLogLevel.debug:
        return Level.debug;
      case AppLogLevel.info:
        return Level.info;
      case AppLogLevel.warning:
        return Level.warning;
      case AppLogLevel.error:
        return Level.error;
      case AppLogLevel.fatal:
        return Level.fatal;
    }
  }
}

class AppLogger {
  AppLogger._({
    required Logger logger,
    AppLogLevel level = AppLogLevel.debug,
  })  : _logger = logger,
        _level = level;

  static AppLogger? _instance;

  static AppLogger get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'AppLogger not initialized. Call AppLogger.init() in main().',
      );
    }
    return i;
  }

  @visibleForTesting
  static set instance(AppLogger logger) => _instance = logger;

  static AppLogger init({AppLogLevel level = AppLogLevel.debug}) {
    final existing = _instance;
    if (existing != null) return existing;

    final prettyPrinter = PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    );

    final logger = Logger(
      level: level.toLevel(),
      printer: prettyPrinter,
      output: ConsoleOutput(),
    );

    final created = AppLogger._(logger: logger, level: level);
    _instance = created;
    return created;
  }

  final Logger _logger;
  final AppLogLevel _level;

  set level(AppLogLevel value) {
    _level.value = value;
    _logger.level = value.toLevel();
  }

  AppLogLevel get level => _level;

  void trace(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _logger.log(Level.trace, message, error: error, stackTrace: stackTrace, time: DateTime.now());
  }

  void debug(String tag, String message) {
    _logger.d('[$tag] $message', time: DateTime.now());
  }

  void info(String tag, String message) {
    _logger.i('[$tag] $message', time: DateTime.now());
  }

  void warning(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w('[$tag] $message', error: error, stackTrace: stackTrace, time: DateTime.now());
  }

  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      '[$tag] $message',
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  void fatal(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(
      '[$tag] $message',
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  void installGlobalHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      fatal(
        'FlutterError',
        details.exceptionAsString(),
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      this.error('PlatformDispatcher', 'Unhandled error', error: error, stackTrace: stack);
      return true;
    };
  }
}

class AppLog {
  AppLog._();

  static void t(String tag, String message) =>
      AppLogger.instance.trace(tag, message);
  static void d(String tag, String message) =>
      AppLogger.instance.debug(tag, message);
  static void i(String tag, String message) =>
      AppLogger.instance.info(tag, message);
  static void w(String tag, String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.instance.warning(tag, message, error: error, stackTrace: stackTrace);
  static void e(String tag, String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.instance.error(tag, message, error: error, stackTrace: stackTrace);
  static void f(String tag, String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.instance.fatal(tag, message, error: error, stackTrace: stackTrace);
}