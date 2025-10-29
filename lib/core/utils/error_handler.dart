// lib/core/utils/error_handler.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';
import 'logger.dart';

/// 🛡️ Gerenciador centralizado de erros
/// 
/// Converte exceções de diferentes fontes (Firebase, Dio, etc) 
/// para AppException padronizado.
class ErrorHandler {
  /// 🔄 Converte qualquer erro para AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Error caught', error, stackTrace);

    // Firebase Auth Errors
    if (error is firebase_auth.FirebaseAuthException) {
      return AuthException.fromFirebaseCode(error.code);
    }

    // Firestore Errors
    if (error is FirebaseException) {
      return _handleFirebaseException(error);
    }

    // Dio Network Errors
    if (error is DioException) {
      return _handleDioException(error);
    }

    // Já é AppException
    if (error is AppException) {
      return error;
    }

    // Erro genérico
    return GenericException(
      error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// 💬 Extrai mensagem amigável para o usuário
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    final appException = handle(error);
    return appException.message;
  }

  /// 👁️ Verifica se deve mostrar erro ao usuário
  static bool shouldDisplayToUser(AppException exception) {
    // Não mostrar erros de validação silenciosos
    if (exception is ValidationException && exception.code == 'silent') {
      return false;
    }
    
    // Não mostrar erros de cache (não críticos)
    if (exception is CacheException) {
      return false;
    }

    // Não mostrar erros de sincronização em background
    if (exception is SyncException && exception.code == 'background') {
      return false;
    }

    return true;
  }

  /// 🎨 Retorna cor apropriada para o erro (hex)
  static String getErrorColor(AppException exception) {
    if (exception is ValidationException) return '#FFA500'; // Orange
    if (exception is NetworkException) return '#FF6B6B'; // Red
    if (exception is AuthException) return '#FF4757'; // Crimson
    if (exception is CacheException) return '#FFD700'; // Gold
    return '#FF0000'; // Default red
  }

  /// 🔔 Retorna ícone apropriado para o erro
  static String getErrorIcon(AppException exception) {
    if (exception is ValidationException) return '⚠️';
    if (exception is NetworkException) return '🌐';
    if (exception is AuthException) return '🔐';
    if (exception is AIException) return '🤖';
    if (exception is SyncException) return '🔄';
    if (exception is CacheException) return '💾';
    if (exception is PermissionException) return '🔒';
    return '❌';
  }

  // ============================================
  // 🔥 Firebase Exception Handler
  // ============================================
  static RepositoryException _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return RepositoryException.permissionDenied();

      case 'unavailable':
        return RepositoryException(
          'Serviço temporariamente indisponível. Tente novamente.',
          code: e.code,
          originalError: e,
        );

      case 'not-found':
        return RepositoryException.notFound('Dados');

      case 'already-exists':
        return RepositoryException.alreadyExists('Registro');

      case 'resource-exhausted':
        return RepositoryException(
          'Limite de requisições excedido. Tente mais tarde.',
          code: e.code,
          originalError: e,
        );

      case 'failed-precondition':
        return RepositoryException(
          'Operação não pode ser realizada no estado atual',
          code: e.code,
          originalError: e,
        );

      case 'aborted':
        return RepositoryException(
          'Operação abortada devido a conflito',
          code: e.code,
          originalError: e,
        );

      case 'out-of-range':
        return RepositoryException(
          'Valor fora do intervalo válido',
          code: e.code,
          originalError: e,
        );

      case 'unimplemented':
        return RepositoryException(
          'Operação não implementada',
          code: e.code,
          originalError: e,
        );

      case 'internal':
        return RepositoryException(
          'Erro interno do servidor',
          code: e.code,
          originalError: e,
        );

      case 'data-loss':
        return RepositoryException(
          'Perda de dados detectada',
          code: e.code,
          originalError: e,
        );

      case 'unauthenticated':
        return RepositoryException(
          'Não autenticado. Faça login novamente.',
          code: e.code,
          originalError: e,
        );

      default:
        return RepositoryException(
          'Erro ao acessar dados: ${e.message}',
          code: e.code,
          originalError: e,
        );
    }
  }

  // ============================================
  // 🌐 Dio Exception Handler
  // ============================================
  static NetworkException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.connectionError:
        return NetworkException.noInternet();

      case DioExceptionType.badResponse:
        return _handleHttpError(e);

      case DioExceptionType.cancel:
        return NetworkException(
          'Requisição cancelada',
          code: 'cancelled',
          originalError: e,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Erro de certificado SSL',
          code: 'bad_certificate',
          originalError: e,
        );

      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') ?? false) {
          return NetworkException.noInternet();
        }
        return NetworkException(
          'Erro de rede: ${e.message}',
          statusCode: e.response?.statusCode,
          originalError: e,
        );
    }
  }

  // ============================================
  // 🔢 HTTP Error Handler
  // ============================================
  static NetworkException _handleHttpError(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final responseData = e.response?.data;

    // Tentar extrair mensagem do servidor
    String? serverMessage;
    if (responseData is Map) {
      serverMessage = responseData['message'] as String? ??
          responseData['error'] as String? ??
          responseData['detail'] as String?;
    }

    switch (statusCode) {
      case 400:
        return NetworkException(
          serverMessage ?? 'Requisição inválida',
          code: 'bad_request',
          statusCode: statusCode,
          originalError: e,
        );

      case 401:
        return NetworkException.unauthorized();

      case 403:
        return NetworkException.forbidden();

      case 404:
        return NetworkException.notFound(
          serverMessage ?? 'Recurso',
        );

      case 422:
        return NetworkException(
          serverMessage ?? 'Dados inválidos',
          code: 'unprocessable_entity',
          statusCode: statusCode,
          originalError: e,
        );

      case 429:
        return NetworkException.rateLimited();

      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkException.serverError(serverMessage);

      default:
        return NetworkException(
          serverMessage ?? 'Erro HTTP $statusCode',
          statusCode: statusCode,
          originalError: e,
        );
    }
  }

  // ============================================
  // 🔄 Retry Logic Helper
  // ============================================
  static bool shouldRetry(AppException exception) {
    if (exception is NetworkException) {
      return exception.isTimeout || 
             exception.isServerError || 
             exception.isRateLimited;
    }
    
    if (exception is RepositoryException) {
      return exception.code == 'unavailable';
    }

    return false;
  }

  /// 📝 Gera relatório detalhado do erro (para logging)
  static Map<String, dynamic> generateErrorReport(
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    final appException = error is AppException 
        ? error 
        : handle(error, stackTrace);

    return {
      'error': appException.toJson(),
      'icon': getErrorIcon(appException),
      'color': getErrorColor(appException),
      'severity': appException.severity,
      'shouldDisplay': shouldDisplayToUser(appException),
      'shouldRetry': shouldRetry(appException),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
