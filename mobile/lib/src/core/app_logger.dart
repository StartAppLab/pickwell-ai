import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/injection_container.dart';

/// Logs operation summaries instead of arbitrary model payloads.
class AppLogger {
  static final Logger _fallbackLogger = Logger();
  static Logger get _logger => getIt.isRegistered<Logger>() ? getIt<Logger>() : _fallbackLogger;

  static String sanitize(String message) => message
      .replaceAll(
        RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
        '[redacted-email]',
      )
      .replaceAll(RegExp(r'\bBearer\s+\S+', caseSensitive: false), 'Bearer [redacted-token]')
      .replaceAll(RegExp(r'\b[A-Za-z0-9_-]{32,}\b'), '[redacted-token]');

  static String _safeValue(Object value) =>
      value is String ? sanitize(value) : 'Log payload omitted: ${value.runtimeType}';

  static void logDebug(Object? message) {
    if (message != null && kDebugMode) _logger.d(_safeValue(message));
  }

  static void logInfo(Object? message) {
    if (message != null && kDebugMode) _logger.i(_safeValue(message));
  }

  static void logException(Object? exception, {StackTrace? stackTrace}) {
    if (exception == null) return;
    final safeException = _SanitizedException(
      exception.runtimeType.toString(),
      sanitize(exception.toString()),
    );
    _logger.e(safeException.toString(), stackTrace: stackTrace);
    _report(() async {
      await Sentry.captureException(safeException, stackTrace: stackTrace);
    });
  }

  static void logWarning(Object? message) => _log(Level.warning, message);
  static void logError(Object? message, {StackTrace? stackTrace}) {
    if (message is Exception || message is Error) {
      logException(message, stackTrace: stackTrace);
    } else {
      _log(Level.error, message, stackTrace: stackTrace);
    }
  }

  static void logFatal(Object? message) => _log(Level.fatal, message);

  static void _log(Level level, Object? message, {StackTrace? stackTrace}) {
    if (message == null) return;
    final safeMessage = _safeValue(message);
    _logger.log(level, safeMessage, stackTrace: stackTrace);
    _report(() async {
      await Sentry.captureMessage(safeMessage);
    });
  }

  static void _report(Future<void> Function() action) {
    unawaited(() async {
      try {
        await action();
      } catch (_) {
        // A reporting failure must not replace the application failure.
      }
    }());
  }
}

class _SanitizedException implements Exception {
  const _SanitizedException(this.type, this.message);
  final String type;
  final String message;

  @override
  String toString() => '$type: $message';
}
