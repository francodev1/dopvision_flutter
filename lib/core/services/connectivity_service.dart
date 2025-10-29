// lib/core/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// 📡 Connectivity Service
/// 
/// Monitora conexão de rede e fornece status de conectividade
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<ConnectivityStatus> _statusController;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        _statusController = StreamController<ConnectivityStatus>.broadcast() {
    _initialize();
  }

  void _initialize() {
    // Monitorar mudanças de conectividade
    _connectivity.onConnectivityChanged.listen((results) {
      final result = results.firstOrNull ?? ConnectivityResult.none;
      final status = _mapResult(result);
      _statusController.add(status);
      _logStatus(status);
    });

    // Verificar status inicial
    checkConnectivity();
  }

  // ============================================
  // 📊 Status de Conectividade
  // ============================================

  /// Verifica conectividade atual
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result = results.firstOrNull ?? ConnectivityResult.none;
      final status = _mapResult(result);
      _statusController.add(status);
      return status;
    } catch (e) {
      AppLogger.error('❌ Erro ao verificar conectividade', e);
      return ConnectivityStatus.disconnected;
    }
  }

  /// Stream de mudanças de conectividade
  Stream<ConnectivityStatus> get onConnectivityChanged {
    return _statusController.stream;
  }

  /// Verifica se está conectado
  Future<bool> get isConnected async {
    final status = await checkConnectivity();
    return status != ConnectivityStatus.disconnected;
  }

  /// Verifica se está em WiFi
  Future<bool> get isWiFi async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.wifi;
  }

  /// Verifica se está em dados móveis
  Future<bool> get isMobile async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.mobile;
  }

  // ============================================
  // 🔄 Helpers
  // ============================================

  /// Mapeia ConnectivityResult para ConnectivityStatus
  ConnectivityStatus _mapResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityStatus.wifi;
      case ConnectivityResult.mobile:
        return ConnectivityStatus.mobile;
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.ethernet;
      case ConnectivityResult.none:
        return ConnectivityStatus.disconnected;
      default:
        return ConnectivityStatus.disconnected;
    }
  }

  /// Loga mudança de status
  void _logStatus(ConnectivityStatus status) {
    final emoji = _getStatusEmoji(status);
    AppLogger.info('$emoji Conectividade: ${status.name}');
  }

  String _getStatusEmoji(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.wifi:
        return '📶';
      case ConnectivityStatus.mobile:
        return '📱';
      case ConnectivityStatus.ethernet:
        return '🔌';
      case ConnectivityStatus.disconnected:
        return '🔴';
    }
  }

  /// Aguarda até ter conexão
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (await isConnected) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = onConnectivityChanged.listen((status) {
      if (status != ConnectivityStatus.disconnected) {
        subscription.cancel();
        completer.complete();
      }
    });

    // Timeout
    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Timeout aguardando conexão'));
      }
    });

    return completer.future;
  }

  // ============================================
  // 🧹 Cleanup
  // ============================================

  void dispose() {
    _statusController.close();
  }
}

// ============================================
// 📋 Enums e Classes
// ============================================

enum ConnectivityStatus {
  wifi,
  mobile,
  ethernet,
  disconnected,
}

// ============================================
// 🎯 Riverpod Providers
// ============================================

/// Provider do ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider do status de conectividade
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Provider booleano: está conectado?
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return await service.isConnected;
});
