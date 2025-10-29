// lib/core/utils/logger.dart
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// 📝 Sistema centralizado de logging
/// 
/// Fornece logging colorido em desenvolvimento e integração com Sentry em produção.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.debug : Level.info,
  );

  // ============================================
  // 🐛 Debug - apenas em desenvolvimento
  // ============================================
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  // ============================================
  // ℹ️ Info - informações gerais
  // ============================================
  static void info(String message, [Map<String, dynamic>? extra]) {
    _logger.i(message);
    
    if (EnvConfig().isProduction && EnvConfig.enableAnalytics && extra != null) {
      // TODO: Integrar com Sentry
      // Sentry.captureMessage(
      //   message,
      //   level: SentryLevel.info,
      //   hint: Hint.withMap(extra),
      // );
    }
  }

  // ============================================
  // ⚠️ Warning - avisos importantes
  // ============================================
  static void warning(
    String message, [
    dynamic error,
    Map<String, dynamic>? extra,
  ]) {
    _logger.w(message, error: error);
    
    if (EnvConfig().isProduction && EnvConfig.enableCrashReports) {
      // TODO: Integrar com Sentry
      // Sentry.captureMessage(
      //   message,
      //   level: SentryLevel.warning,
      //   hint: extra != null ? Hint.withMap(extra) : null,
      // );
    }
  }

  // ============================================
  // 🔴 Error - erros críticos
  // ============================================
  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    
    // Enviar para Sentry em produção
    if (EnvConfig().isProduction && EnvConfig.enableCrashReports) {
      // TODO: Integrar com Sentry
      // Sentry.captureException(
      //   error ?? Exception(message),
      //   stackTrace: stackTrace,
      //   hint: extra != null ? Hint.withMap(extra) : null,
      // );
    }
  }

  // ============================================
  // ☠️ Fatal - erros que causam crash
  // ============================================
  static void fatal(
    String message,
    dynamic error,
    StackTrace stackTrace, [
    Map<String, dynamic>? extra,
  ]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    
    // TODO: Integrar com Sentry
    // Sentry.captureException(
    //   error,
    //   stackTrace: stackTrace,
    //   hint: extra != null ? Hint.withMap(extra) : null,
    // );
  }

  // ============================================
  // 📊 Event tracking
  // ============================================
  static void logEvent(String eventName, Map<String, dynamic> parameters) {
    if (kDebugMode) {
      _logger.i('📊 Event: $eventName', error: parameters);
    }
    
    // TODO: Firebase Analytics
    // if (EnvConfig.enableAnalytics) {
    //   FirebaseAnalytics.instance.logEvent(
    //     name: eventName,
    //     parameters: parameters,
    //   );
    // }
  }

  // ============================================
  // 👤 User action tracking
  // ============================================
  static void logUserAction(String action, [Map<String, dynamic>? data]) {
    info('👤 User Action: $action', data);
  }

  // ============================================
  // 🌐 API request logging
  // ============================================
  static void logApiRequest(
    String method,
    String url, [
    Map<String, dynamic>? data,
  ]) {
    if (kDebugMode) {
      _logger.d('🌐 API Request: $method $url', error: data);
    }
  }

  // ============================================
  // 🌐 API response logging
  // ============================================
  static void logApiResponse(
    int statusCode,
    String url, [
    dynamic data,
  ]) {
    if (kDebugMode) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      _logger.d('$emoji API Response: $statusCode $url', error: data);
    }
  }

  // ============================================
  // 🔄 Sync logging
  // ============================================
  static void logSync(String operation, {bool success = true}) {
    if (kDebugMode) {
      final emoji = success ? '✅' : '❌';
      _logger.d('$emoji Sync: $operation');
    }
  }

  // ============================================
  // 🤖 AI logging
  // ============================================
  static void logAI(String operation, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      _logger.d('🤖 AI: $operation', error: data);
    }
  }

  // ============================================
  // 🔔 Notification logging
  // ============================================
  static void logNotification(String title, [String? body]) {
    if (kDebugMode) {
      _logger.d('🔔 Notification: $title${body != null ? ' - $body' : ''}');
    }
  }

  // ============================================
  // 💾 Cache logging
  // ============================================
  static void logCache(String operation, String key, {bool hit = false}) {
    if (kDebugMode) {
      final emoji = hit ? '✅' : '❌';
      _logger.d('💾 Cache $operation: $key $emoji');
    }
  }

  // ============================================
  // 🔗 Navigation logging
  // ============================================
  static void logNavigation(String route, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      _logger.d('🔗 Navigation: $route', error: params);
    }
  }

  // ============================================
  // ⏱️ Performance logging
  // ============================================
  static void logPerformance(String operation, Duration duration) {
    if (kDebugMode) {
      _logger.d('⏱️ Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }
}
