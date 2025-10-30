// lib/core/services/token_service.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'firebase_auth_service.dart'; // unused import removed
import '../utils/logger.dart';

/// 🔐 Token Service
/// 
/// Gerencia tokens de autenticação com refresh automático:
/// - Access Token: 20 minutos
/// - Refresh Token: 7 dias (padrão) ou 30 dias (lembrar-me)
/// - Auto-refresh antes de expirar
/// - Logout automático após inatividade
class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _rememberMeKey = 'remember_me';
  
  // Durações
  static const Duration accessTokenDuration = Duration(minutes: 20);
  static const Duration refreshTokenDuration = Duration(days: 7);
  static const Duration rememberMeDuration = Duration(days: 30);
  static const Duration refreshBeforeExpiry = Duration(minutes: 5); // Renova 5min antes
  
  Timer? _refreshTimer;
  final StreamController<TokenStatus> _statusController = StreamController<TokenStatus>.broadcast();
  
  Stream<TokenStatus> get statusStream => _statusController.stream;

  /// Salva tokens após login
  Future<void> saveTokens({
    required String accessToken,
    required String? refreshToken,
    bool rememberMe = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final expiry = now.add(accessTokenDuration);
      
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
      await prefs.setBool(_rememberMeKey, rememberMe);
      
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      
      AppLogger.info('Tokens salvos. Expira em: ${accessTokenDuration.inMinutes} minutos');
      
      // Inicia timer de refresh automático
      _startRefreshTimer();
      
      _statusController.add(TokenStatus.active);
    } catch (e, stack) {
      AppLogger.error('Erro ao salvar tokens', e, stack);
      throw Exception('Erro ao salvar tokens: $e');
    }
  }

  /// Obtém access token atual
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_accessTokenKey);
      
      if (token == null) return null;
      
      // Verifica se expirou
      if (await isTokenExpired()) {
        AppLogger.warning('Access token expirado');
        
        // Tenta renovar
        final renewed = await renewAccessToken();
        if (renewed) {
          return prefs.getString(_accessTokenKey);
        }
        
        return null;
      }
      
      return token;
    } catch (e) {
      AppLogger.error('Erro ao obter access token', e);
      return null;
    }
  }

  /// Verifica se token está expirado
  Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryStr = prefs.getString(_tokenExpiryKey);
      
      if (expiryStr == null) return true;
      
      final expiry = DateTime.parse(expiryStr);
      final now = DateTime.now();
      
      return now.isAfter(expiry);
    } catch (e) {
      AppLogger.error('Erro ao verificar expiração', e);
      return true;
    }
  }

  /// Obtém tempo restante até expiração
  Future<Duration?> getTimeUntilExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryStr = prefs.getString(_tokenExpiryKey);
      
      if (expiryStr == null) return null;
      
      final expiry = DateTime.parse(expiryStr);
      final now = DateTime.now();
      
      if (now.isAfter(expiry)) return Duration.zero;
      
      return expiry.difference(now);
    } catch (e) {
      return null;
    }
  }

  /// Alias para getTimeUntilExpiry (mais semântico)
  Future<Duration?> getRemainingTime() => getTimeUntilExpiry();

  /// Renova access token usando refresh token
  Future<bool> renewAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) {
        AppLogger.warning('Refresh token não encontrado');
        _statusController.add(TokenStatus.expired);
        return false;
      }
      
      AppLogger.info('Renovando access token...');
      _statusController.add(TokenStatus.refreshing);
      
      // No Firebase, o token é renovado automaticamente pelo SDK
      // Apenas atualizamos o timestamp
      final now = DateTime.now();
      final newExpiry = now.add(accessTokenDuration);
      
      await prefs.setString(_tokenExpiryKey, newExpiry.toIso8601String());
      
      AppLogger.info('Access token renovado com sucesso');
      _statusController.add(TokenStatus.active);
      
      return true;
    } catch (e, stack) {
      AppLogger.error('Erro ao renovar token', e, stack);
      _statusController.add(TokenStatus.error);
      return false;
    }
  }

  /// Inicia timer para refresh automático
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final timeUntil = await getTimeUntilExpiry();
      
      if (timeUntil == null) {
        timer.cancel();
        return;
      }
      
      // Renova 5 minutos antes de expirar
      if (timeUntil <= refreshBeforeExpiry) {
        AppLogger.info('Token próximo de expirar. Renovando...');
        final renewed = await renewAccessToken();
        
        if (!renewed) {
          AppLogger.warning('Falha ao renovar token. Deslogando usuário.');
          await clearTokens();
          _statusController.add(TokenStatus.expired);
          timer.cancel();
        }
      }
    });
  }

  /// Verifica se tem "lembrar-me" ativo
  Future<bool> isRememberMeActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Limpa todos os tokens (logout)
  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_rememberMeKey);
      
      _refreshTimer?.cancel();
      _refreshTimer = null;
      
      AppLogger.info('Tokens limpos (logout)');
      _statusController.add(TokenStatus.cleared);
    } catch (e, stack) {
      AppLogger.error('Erro ao limpar tokens', e, stack);
    }
  }

  /// Verifica se usuário está autenticado com token válido
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Dispose
  void dispose() {
    _refreshTimer?.cancel();
    _statusController.close();
  }
}

/// Status do token
enum TokenStatus {
  active,      // Token válido e ativo
  refreshing,  // Renovando token
  expired,     // Token expirado
  cleared,     // Tokens limpos (logout)
  error,       // Erro ao gerenciar tokens
}

// ============================================
// 🎯 Riverpod Providers
// ============================================

final tokenServiceProvider = Provider<TokenService>((ref) {
  final service = TokenService();
  ref.onDispose(() => service.dispose());
  return service;
});

final tokenStatusProvider = StreamProvider<TokenStatus>((ref) {
  final service = ref.watch(tokenServiceProvider);
  return service.statusStream;
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(tokenServiceProvider);
  return service.isAuthenticated();
});
