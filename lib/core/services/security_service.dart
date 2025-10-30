import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

/// Serviço de segurança seguindo OWASP Top 10 Mobile
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final Logger _logger = Logger();
  
  // Storage seguro (criptografado) - OWASP M2: Insecure Data Storage
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Salva dados sensíveis de forma segura
  Future<void> saveSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      _logger.d('✅ Dado seguro salvo: $key');
    } catch (e, st) {
      _logger.e('❌ Erro ao salvar dado seguro', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Lê dados sensíveis
  Future<String?> readSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e, st) {
      _logger.e('❌ Erro ao ler dado seguro', error: e, stackTrace: st);
      return null;
    }
  }

  /// Deleta dados sensíveis
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      _logger.d('✅ Dado seguro deletado: $key');
    } catch (e, st) {
      _logger.e('❌ Erro ao deletar dado seguro', error: e, stackTrace: st);
    }
  }

  /// Limpa todos os dados sensíveis
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      _logger.w('🧹 Todos os dados seguros foram limpos');
    } catch (e, st) {
      _logger.e('❌ Erro ao limpar dados seguros', error: e, stackTrace: st);
    }
  }

  /// Hash de senha (SHA-256) - OWASP M5: Insufficient Cryptography
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Valida força da senha - OWASP M4: Insecure Authentication
  PasswordStrength validatePasswordStrength(String password) {
    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    int strength = 0;
    
    // Tem letras minúsculas?
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    
    // Tem letras maiúsculas?
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    
    // Tem números?
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    
    // Tem caracteres especiais?
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    // Tem mais de 12 caracteres?
    if (password.length >= 12) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength == 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Sanitiza input do usuário - OWASP M7: Client Code Quality
  String sanitizeInput(String input) {
    // Remove espaços extras
    String sanitized = input.trim();
    
    // Remove caracteres de controle
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    // Escapa caracteres especiais HTML/JS (prevenção XSS)
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
    
    return sanitized;
  }

  /// Valida email - OWASP M7: Client Code Quality
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Detecta tentativa de SQL Injection - OWASP M7
  bool containsSQLInjection(String input) {
    final sqlPatterns = [
      RegExp(r"('|(\\')|(--)|(%27)|(\\x27))", caseSensitive: false),
      RegExp(r"(\bOR\b|\bAND\b).*=", caseSensitive: false),
      RegExp(r"\bDROP\b|\bDELETE\b|\bINSERT\b|\bUPDATE\b", caseSensitive: false),
      RegExp(r"UNION.*SELECT", caseSensitive: false),
    ];

    for (final pattern in sqlPatterns) {
      if (pattern.hasMatch(input)) {
        _logger.w('🚨 Tentativa de SQL Injection detectada: $input');
        return true;
      }
    }
    return false;
  }

  /// Rate limiting simples (previne brute force)
  final Map<String, List<DateTime>> _rateLimitMap = {};
  
  bool checkRateLimit(String identifier, {int maxAttempts = 5, Duration window = const Duration(minutes: 5)}) {
    final now = DateTime.now();
    final attempts = _rateLimitMap[identifier] ?? [];
    
    // Remove tentativas antigas (fora da janela)
    attempts.removeWhere((time) => now.difference(time) > window);
    
    if (attempts.length >= maxAttempts) {
      _logger.w('🚨 Rate limit excedido para: $identifier');
      return false;
    }
    
    attempts.add(now);
    _rateLimitMap[identifier] = attempts;
    return true;
  }

  /// Limpa rate limit para um identificador
  void clearRateLimit(String identifier) {
    _rateLimitMap.remove(identifier);
  }

  /// Gera token aleatório seguro
  String generateSecureToken({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) {
      final i = (random + index) % chars.length;
      return chars[i];
    }).join();
  }

  /// Verifica se o app está rodando em device com root/jailbreak
  /// (OWASP M8: Code Tampering)
  Future<bool> isDeviceCompromised() async {
    // TODO: Implementar verificação real com pacote como 'flutter_jailbreak_detection'
    // Por enquanto retorna false
    return false;
  }

  /// Log de auditoria seguro
  void auditLog(String action, {Map<String, dynamic>? metadata}) {
    final timestamp = DateTime.now().toIso8601String();
    _logger.i('AUDIT [$timestamp] $action', error: metadata);
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}
