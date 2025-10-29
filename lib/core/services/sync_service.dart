// lib/core/services/sync_service.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';
import '../utils/logger.dart';
import '../exceptions/app_exception.dart';

/// 🔄 Sync Service
/// 
/// Gerencia sincronização offline-first entre cache local e Firestore
class SyncService {
  final ConnectivityService _connectivity;
  
  final StreamController<SyncStatus> _statusController;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService({
    required ConnectivityService connectivity,
  })  : _connectivity = connectivity,
        _statusController = StreamController<SyncStatus>.broadcast() {
    _initialize();
  }

  void _initialize() {
    // Monitorar mudanças de conectividade
    _connectivity.onConnectivityChanged.listen((status) {
      if (status != ConnectivityStatus.disconnected) {
        AppLogger.info('✅ Conexão restaurada, iniciando sync');
        sync();
      }
    });

    // Sync periódico (a cada 5 minutos)
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      sync();
    });
  }

  // ============================================
  // 🔄 Sincronização
  // ============================================

  /// Stream de status de sync
  Stream<SyncStatus> get onSyncStatusChanged => _statusController.stream;

  /// Está sincronizando?
  bool get isSyncing => _isSyncing;

  /// Sincroniza dados pendentes
  Future<void> sync({bool force = false}) async {
    // Evitar sync simultâneo
    if (_isSyncing && !force) {
      AppLogger.info('⏭️ Sync já em andamento, ignorando');
      return;
    }

    // Verificar conectividade
    if (!await _connectivity.isConnected) {
      AppLogger.warning('⚠️ Sem conexão, sync adiado');
      _updateStatus(SyncStatus.waitingForConnection);
      return;
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      AppLogger.info('🔄 Iniciando sincronização');

      // 1. Sync pendências (uploads locais → Firestore)
      await _syncPendingUploads();

      // 2. Sync dados remotos (Firestore → local cache)
      await _syncRemoteData();

      AppLogger.info('✅ Sincronização concluída');
      _updateStatus(SyncStatus.success);
    } on SyncException catch (e) {
      AppLogger.error('❌ Erro na sincronização', e);
      _updateStatus(SyncStatus.error);
      rethrow;
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado no sync', e, stack);
      _updateStatus(SyncStatus.error);
      throw SyncException('Erro ao sincronizar: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync apenas upload (local → remoto)
  Future<void> syncUpload() async {
    if (!await _connectivity.isConnected) {
      throw SyncException('Sem conexão para upload');
    }

    _updateStatus(SyncStatus.uploading);
    await _syncPendingUploads();
    _updateStatus(SyncStatus.success);
  }

  /// Sync apenas download (remoto → local)
  Future<void> syncDownload() async {
    if (!await _connectivity.isConnected) {
      throw SyncException('Sem conexão para download');
    }

    _updateStatus(SyncStatus.downloading);
    await _syncRemoteData();
    _updateStatus(SyncStatus.success);
  }

  // ============================================
  // 📤 Upload de Pendências
  // ============================================

  Future<void> _syncPendingUploads() async {
    try {
      AppLogger.info('📤 Sincronizando pendências locais');

      // TODO: Implementar lógica específica
      // 1. Buscar operações pendentes do cache local (Hive)
      // 2. Para cada operação:
      //    - Tentar executar no Firestore
      //    - Se sucesso, remover do cache de pendências
      //    - Se erro, manter no cache para retry

      // Exemplo (pseudo-código):
      // final pendingOps = await _localCache.getPendingOperations();
      // for (final op in pendingOps) {
      //   try {
      //     await _executePendingOperation(op);
      //     await _localCache.removePendingOperation(op.id);
      //   } catch (e) {
      //     AppLogger.warning('⚠️ Falha ao sync operação ${op.id}');
      //   }
      // }

      AppLogger.info('✅ Upload de pendências concluído');
    } catch (e, stack) {
      AppLogger.error('❌ Erro no upload de pendências', e, stack);
      rethrow;
    }
  }

  // ============================================
  // 📥 Download de Dados Remotos
  // ============================================

  Future<void> _syncRemoteData() async {
    try {
      AppLogger.info('📥 Baixando dados remotos');

      // TODO: Implementar lógica específica
      // 1. Buscar timestamp do último sync
      // 2. Buscar dados modificados após esse timestamp
      // 3. Atualizar cache local com novos dados
      // 4. Atualizar timestamp do último sync

      // Exemplo (pseudo-código):
      // final lastSync = await _localCache.getLastSyncTimestamp();
      // 
      // final newClients = await _clientRepo.getWhere(
      //   filters: [QueryFilter(field: 'updatedAt', isGreaterThan: lastSync)],
      // );
      // await _localCache.saveClients(newClients);
      //
      // await _localCache.setLastSyncTimestamp(DateTime.now());

      AppLogger.info('✅ Download de dados concluído');
    } catch (e, stack) {
      AppLogger.error('❌ Erro no download de dados', e, stack);
      rethrow;
    }
  }

  // ============================================
  // 🎯 Sync Específico
  // ============================================

  /// Sincroniza clientes
  Future<void> syncClients({String? userId}) async {
    AppLogger.info('👥 Sincronizando clientes');
    // TODO: Implementar sync específico de clientes
  }

  /// Sincroniza campanhas
  Future<void> syncCampaigns({String? clientId}) async {
    AppLogger.info('📢 Sincronizando campanhas');
    // TODO: Implementar sync específico de campanhas
  }

  /// Sincroniza vendas
  Future<void> syncSales({String? campaignId}) async {
    AppLogger.info('💰 Sincronizando vendas');
    // TODO: Implementar sync específico de vendas
  }

  // ============================================
  // 🔔 Notificações de Sync
  // ============================================

  void _updateStatus(SyncStatus status) {
    _statusController.add(status);
    AppLogger.logSync('status_change: ${status.name}');
  }

  // ============================================
  // 🛠️ Utilitários
  // ============================================

  /// Limpa cache local
  Future<void> clearCache() async {
    try {
      AppLogger.warning('🗑️ Limpando cache local');
      // TODO: Implementar limpeza do cache
      AppLogger.info('✅ Cache limpo');
    } catch (e, stack) {
      AppLogger.error('❌ Erro ao limpar cache', e, stack);
      rethrow;
    }
  }

  /// Reseta sincronização (força full sync)
  Future<void> resetSync() async {
    try {
      AppLogger.warning('🔄 Resetando sincronização');
      // TODO: Resetar timestamp do último sync
      await sync(force: true);
    } catch (e, stack) {
      AppLogger.error('❌ Erro ao resetar sync', e, stack);
      rethrow;
    }
  }

  // ============================================
  // 🧹 Cleanup
  // ============================================

  void dispose() {
    _syncTimer?.cancel();
    _statusController.close();
  }
}

// ============================================
// 📋 Enums
// ============================================

enum SyncStatus {
  idle,
  waitingForConnection,
  syncing,
  uploading,
  downloading,
  success,
  error,
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

/// Provider do SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  
  final service = SyncService(
    connectivity: connectivity,
  );
  
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider do status de sync
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.onSyncStatusChanged;
});
