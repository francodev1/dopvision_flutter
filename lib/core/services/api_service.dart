// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';
import '../exceptions/app_exception.dart';

/// 🌐 API Service
/// 
/// Cliente HTTP com Dio para APIs externas (n8n, webhooks, etc)
class ApiService {
  late final Dio _dio;

  ApiService({Dio? dio}) {
    _dio = dio ?? _createDio();
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor de logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.logApiRequest(
            options.method,
            options.uri.toString(),
            options.data,
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.logApiResponse(
            response.statusCode ?? 0,
            response.requestOptions.uri.toString(),
            response.data,
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            '❌ API Error: ${error.message}',
            error,
            error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );

    // Interceptor de retry
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // ============================================
  // 🔄 HTTP Methods
  // ============================================

  /// GET request
  Future<T> get<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no GET', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// POST request
  Future<T> post<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no POST', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// PUT request
  Future<T> put<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no PUT', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// PATCH request
  Future<T> patch<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no PATCH', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no DELETE', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 📤 Upload/Download
  // ============================================

  /// Upload de arquivo
  Future<T> uploadFile<T>({
    required String url,
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
    Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: onProgress,
      );

      return response.data as T;
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no upload', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Download de arquivo
  Future<void> downloadFile({
    required String url,
    required String savePath,
    Function(int, int)? onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro no download', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🎯 n8n Webhooks (DoPVision específico)
  // ============================================

  /// Envia dados para webhook do n8n
  Future<Map<String, dynamic>> sendToN8n({
    required String webhookPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = '${EnvConfig.n8nBaseUrl}/$webhookPath';

      AppLogger.info('📤 Enviando para n8n: $webhookPath');

      final response = await post<Map<String, dynamic>>(
        url: url,
        data: data,
        headers: {
          'X-API-Key': EnvConfig.n8nApiKey,
        },
      );

      AppLogger.info('✅ Resposta do n8n recebida');
      return response;
    } catch (e) {
      AppLogger.error('❌ Erro ao enviar para n8n', e);
      rethrow;
    }
  }

  /// Webhook: Sincroniza campanha
  Future<void> syncCampaign(Map<String, dynamic> campaignData) async {
    await sendToN8n(
      webhookPath: 'sync-campaign',
      data: campaignData,
    );
  }

  /// Webhook: Processa venda
  Future<void> processSale(Map<String, dynamic> saleData) async {
    await sendToN8n(
      webhookPath: 'process-sale',
      data: saleData,
    );
  }

  /// Webhook: Notificação
  Future<void> sendNotification(Map<String, dynamic> notificationData) async {
    await sendToN8n(
      webhookPath: 'send-notification',
      data: notificationData,
    );
  }

  // ============================================
  // 🛠️ Utilitários
  // ============================================

  /// Verifica se deve fazer retry
  bool _shouldRetry(DioException error) {
    // Retry em erros de timeout ou conexão
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  /// Faz retry da request
  Future<Response> _retry(RequestOptions requestOptions) async {
    const maxRetries = 3;
    int retries = 0;

    while (retries < maxRetries) {
      try {
        AppLogger.info('🔄 Retry ${retries + 1}/$maxRetries');
        
        // Aguardar antes de tentar novamente (exponential backoff)
        await Future.delayed(Duration(seconds: (retries + 1) * 2));

        return await _dio.fetch(requestOptions);
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          rethrow;
        }
      }
    }

    throw NetworkException('Max retries exceeded');
  }

  /// Cancela todas as requests pendentes
  void cancelAll() {
    _dio.close(force: true);
  }
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

/// Provider do ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
