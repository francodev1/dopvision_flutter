// lib/core/exceptions/app_exception.dart

/// 🚨 Exceção base para toda a aplicação
/// 
/// Todas as exceções customizadas devem estender esta classe.
/// Fornece estrutura consistente para tratamento de erros.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (code != null) {
      return '[$code] $message';
    }
    return message;
  }

  /// Converte para Map para logging e analytics
  Map<String, dynamic> toJson() => {
        'type': runtimeType.toString(),
        'message': message,
        'code': code,
        'timestamp': DateTime.now().toIso8601String(),
        'hasOriginalError': originalError != null,
        'hasStackTrace': stackTrace != null,
      };

  /// Determina a severidade do erro
  String get severity {
    if (this is NetworkException) return 'warning';
    if (this is CacheException) return 'info';
    if (this is ValidationException) return 'info';
    return 'error';
  }
}

// ============================================
// ❗ Exceção Genérica
// ============================================

class GenericException extends AppException {
  const GenericException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// ============================================
// 📦 Erros de Repositório (Firestore, Cache)
// ============================================

class RepositoryException extends AppException {
  const RepositoryException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory RepositoryException.notFound(String entity) {
    return RepositoryException(
      '$entity não encontrado',
      code: 'not_found',
    );
  }

  factory RepositoryException.alreadyExists(String entity) {
    return RepositoryException(
      '$entity já existe',
      code: 'already_exists',
    );
  }

  factory RepositoryException.permissionDenied() {
    return const RepositoryException(
      'Você não tem permissão para esta ação',
      code: 'permission_denied',
    );
  }

  factory RepositoryException.operationFailed(String operation) {
    return RepositoryException(
      'Falha ao $operation',
      code: 'operation_failed',
    );
  }
}

// ============================================
// 🌐 Erros de Rede e APIs Externas
// ============================================

class NetworkException extends AppException {
  final int? statusCode;
  
  const NetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  bool get isTimeout => code == 'timeout';
  bool get isNoInternet => code == 'no_internet';
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'statusCode': statusCode,
      };

  factory NetworkException.timeout() {
    return const NetworkException(
      'Tempo de conexão esgotado. Verifique sua internet.',
      code: 'timeout',
    );
  }

  factory NetworkException.noInternet() {
    return const NetworkException(
      'Sem conexão com a internet',
      code: 'no_internet',
    );
  }

  factory NetworkException.serverError([String? details]) {
    return NetworkException(
      details ?? 'Erro no servidor. Tente novamente mais tarde.',
      code: 'server_error',
      statusCode: 500,
    );
  }

  factory NetworkException.unauthorized() {
    return const NetworkException(
      'Não autorizado. Faça login novamente.',
      code: 'unauthorized',
      statusCode: 401,
    );
  }

  factory NetworkException.forbidden() {
    return const NetworkException(
      'Acesso negado',
      code: 'forbidden',
      statusCode: 403,
    );
  }

  factory NetworkException.notFound(String resource) {
    return NetworkException(
      '$resource não encontrado',
      code: 'not_found',
      statusCode: 404,
    );
  }

  factory NetworkException.rateLimited() {
    return const NetworkException(
      'Muitas requisições. Aguarde um momento.',
      code: 'rate_limit',
      statusCode: 429,
    );
  }
}

// ============================================
// 🔐 Erros de Autenticação
// ============================================

class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Factory para converter códigos do Firebase Auth
  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthException('Usuário não encontrado', code: code);
      case 'wrong-password':
        return AuthException('Senha incorreta', code: code);
      case 'email-already-in-use':
        return AuthException('Email já está em uso', code: code);
      case 'weak-password':
        return AuthException('Senha muito fraca. Use no mínimo 6 caracteres.', code: code);
      case 'invalid-email':
        return AuthException('Email inválido', code: code);
      case 'user-disabled':
        return AuthException('Usuário desabilitado', code: code);
      case 'too-many-requests':
        return AuthException('Muitas tentativas. Tente mais tarde', code: code);
      case 'operation-not-allowed':
        return AuthException('Operação não permitida', code: code);
      case 'account-exists-with-different-credential':
        return AuthException('Conta existe com credencial diferente', code: code);
      case 'invalid-credential':
        return AuthException('Credenciais inválidas', code: code);
      case 'invalid-verification-code':
        return AuthException('Código de verificação inválido', code: code);
      case 'invalid-verification-id':
        return AuthException('ID de verificação inválido', code: code);
      default:
        return AuthException('Erro de autenticação: $code', code: code);
    }
  }

  factory AuthException.notAuthenticated() {
    return const AuthException(
      'Usuário não autenticado',
      code: 'not_authenticated',
    );
  }

  factory AuthException.sessionExpired() {
    return const AuthException(
      'Sessão expirada. Faça login novamente.',
      code: 'session_expired',
    );
  }
}

// ============================================
// 🤖 Erros de IA (OpenAI, Gemini, etc)
// ============================================

class AIException extends AppException {
  const AIException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  bool get isQuotaExceeded => code == 'quota_exceeded';
  bool get isInvalidRequest => code == 'invalid_request';
  bool get isModelUnavailable => code == 'model_unavailable';
  bool get isRateLimited => code == 'rate_limited';

  factory AIException.quotaExceeded() {
    return const AIException(
      'Limite de uso de IA excedido',
      code: 'quota_exceeded',
    );
  }

  factory AIException.invalidRequest(String reason) {
    return AIException(
      'Requisição inválida: $reason',
      code: 'invalid_request',
    );
  }

  factory AIException.modelUnavailable(String model) {
    return AIException(
      'Modelo $model indisponível',
      code: 'model_unavailable',
    );
  }

  factory AIException.rateLimited() {
    return const AIException(
      'Limite de requisições de IA excedido. Tente novamente em alguns minutos.',
      code: 'rate_limited',
    );
  }
}

// ============================================
// ✅ Erros de Validação
// ============================================

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'fieldErrors': fieldErrors,
      };

  factory ValidationException.required(String field) {
    return ValidationException(
      '$field é obrigatório',
      code: 'required',
      fieldErrors: {field: 'Campo obrigatório'},
    );
  }

  factory ValidationException.invalidFormat(String field, String format) {
    return ValidationException(
      '$field está em formato inválido. Esperado: $format',
      code: 'invalid_format',
      fieldErrors: {field: 'Formato inválido'},
    );
  }

  factory ValidationException.tooShort(String field, int minLength) {
    return ValidationException(
      '$field deve ter no mínimo $minLength caracteres',
      code: 'too_short',
      fieldErrors: {field: 'Muito curto'},
    );
  }

  factory ValidationException.tooLong(String field, int maxLength) {
    return ValidationException(
      '$field deve ter no máximo $maxLength caracteres',
      code: 'too_long',
      fieldErrors: {field: 'Muito longo'},
    );
  }
}

// ============================================
// 🔄 Erros de Sincronização Offline
// ============================================

class SyncException extends AppException {
  const SyncException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory SyncException.conflictDetected(String entity) {
    return SyncException(
      'Conflito detectado ao sincronizar $entity',
      code: 'conflict',
    );
  }

  factory SyncException.syncFailed(String reason) {
    return SyncException(
      'Falha na sincronização: $reason',
      code: 'sync_failed',
    );
  }
}

// ============================================
// 💾 Erros de Cache
// ============================================

class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory CacheException.notFound(String key) {
    return CacheException(
      'Cache não encontrado para: $key',
      code: 'not_found',
    );
  }

  factory CacheException.writeFailed() {
    return const CacheException(
      'Falha ao escrever no cache',
      code: 'write_failed',
    );
  }

  factory CacheException.readFailed() {
    return const CacheException(
      'Falha ao ler do cache',
      code: 'read_failed',
    );
  }
}

// ============================================
// 🔒 Erros de Permissão
// ============================================

class PermissionException extends AppException {
  final String permission;

  const PermissionException(
    super.message, {
    required this.permission,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory PermissionException.denied(String permission) {
    return PermissionException(
      'Permissão negada: $permission',
      permission: permission,
      code: 'denied',
    );
  }

  factory PermissionException.notGranted(String permission) {
    return PermissionException(
      'Permissão não concedida: $permission',
      permission: permission,
      code: 'not_granted',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'permission': permission,
      };
}
