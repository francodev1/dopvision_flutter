// lib/core/repositories/client_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client_model.dart';
import 'base_repository.dart';
import '../utils/logger.dart';

/// 🏢 Client Repository - Gerencia operações de clientes
/// 
/// Herda operações CRUD do BaseRepository e adiciona métodos específicos.
class ClientRepository extends BaseRepository<ClientModel> {
  final String? userId;

  ClientRepository({this.userId});

  @override
  String get collectionName => 'clients';

  @override
  ClientModel fromFirestore(DocumentSnapshot doc) {
    return ClientModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(ClientModel model) {
    return model.toFirestore();
  }

  // ============================================
  // 📋 Métodos Específicos de Cliente
  // ============================================

  /// Busca clientes do usuário atual
  Future<List<ClientModel>> getByUserId(String userId, {
    int? limit,
    ClientStatus? status,
  }) async {
    try {
      AppLogger.debug('Fetching clients for user: $userId');

      Query query = collection.where('userId', isEqualTo: userId);

      // Filtrar apenas ativos (não deletados)
      query = query.where('isDeleted', isEqualTo: false);

      // Filtrar por status se especificado
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      // Ordenar por nome
      query = query.orderBy('name');

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final clients = snapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();

      AppLogger.info('Found ${clients.length} clients for user $userId');
      return clients;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching clients for user', e, stackTrace);
      rethrow;
    }
  }

  /// Stream de clientes do usuário
  Stream<List<ClientModel>> watchByUserId(String userId, {
    ClientStatus? status,
  }) {
    try {
      AppLogger.debug('Watching clients for user: $userId');

      Query query = collection
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('name');

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error watching clients', e, stackTrace);
      rethrow;
    }
  }

  /// Busca clientes por tipo
  Future<List<ClientModel>> getByType(
    String userId,
    ClientType type,
  ) async {
    try {
      AppLogger.debug('Fetching $type clients for user: $userId');

      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching clients by type', e, stackTrace);
      rethrow;
    }
  }

  /// Busca clientes por segmento
  Future<List<ClientModel>> getBySegment(
    String userId,
    String segment,
  ) async {
    try {
      AppLogger.debug('Fetching clients in segment: $segment');

      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('segment', isEqualTo: segment)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching clients by segment', e, stackTrace);
      rethrow;
    }
  }

  /// Busca clientes por plano
  Future<List<ClientModel>> getByPlan(
    String userId,
    PlanType plan,
  ) async {
    try {
      AppLogger.debug('Fetching clients with plan: $plan');

      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('plan', isEqualTo: plan.name)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching clients by plan', e, stackTrace);
      rethrow;
    }
  }

  /// Busca clientes por tag
  Future<List<ClientModel>> getByTag(
    String userId,
    String tag,
  ) async {
    try {
      AppLogger.debug('Fetching clients with tag: $tag');

      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('tags', arrayContains: tag)
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching clients by tag', e, stackTrace);
      rethrow;
    }
  }

  /// Busca clientes com meta acima de um valor
  Future<List<ClientModel>> getByMinGoal(
    String userId,
    double minGoal,
  ) async {
    try {
      AppLogger.debug('Fetching clients with goal >= $minGoal');

      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('monthlyGoal', isGreaterThanOrEqualTo: minGoal)
          .where('isDeleted', isEqualTo: false)
          .orderBy('monthlyGoal', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching clients by min goal', e, stackTrace);
      rethrow;
    }
  }

  /// Busca clientes recentes
  Future<List<ClientModel>> getRecent(
    String userId, {
    int limit = 10,
  }) async {
    try {
      AppLogger.debug('Fetching $limit recent clients');

      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching recent clients', e, stackTrace);
      rethrow;
    }
  }

  /// Pesquisa clientes por nome
  Future<List<ClientModel>> searchByName(
    String userId,
    String query,
  ) async {
    try {
      AppLogger.debug('Searching clients with query: $query');

      // Firestore não tem full-text search nativo
      // Vamos buscar todos e filtrar no cliente
      final allClients = await getByUserId(userId);

      final searchQuery = query.toLowerCase();
      return allClients
          .where((client) => client.name.toLowerCase().contains(searchQuery))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error searching clients', e, stackTrace);
      rethrow;
    }
  }

  /// Conta clientes ativos do usuário
  Future<int> countActive(String userId) async {
    try {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ClientStatus.active.name)
          .where('isDeleted', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      AppLogger.error('Error counting active clients', e, stackTrace);
      rethrow;
    }
  }

  /// Atualiza status do cliente
  Future<void> updateStatus(String id, ClientStatus status) async {
    try {
      AppLogger.debug('Updating client $id status to $status');

      await updateFields(id, {'status': status.name});
      AppLogger.info('Client status updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating client status', e, stackTrace);
      rethrow;
    }
  }

  /// Adiciona tag ao cliente
  Future<void> addTag(String id, String tag) async {
    try {
      AppLogger.debug('Adding tag "$tag" to client $id');

      await collection.doc(id).update({
        'tags': FieldValue.arrayUnion([tag]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Tag added successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error adding tag', e, stackTrace);
      rethrow;
    }
  }

  /// Remove tag do cliente
  Future<void> removeTag(String id, String tag) async {
    try {
      AppLogger.debug('Removing tag "$tag" from client $id');

      await collection.doc(id).update({
        'tags': FieldValue.arrayRemove([tag]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Tag removed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error removing tag', e, stackTrace);
      rethrow;
    }
  }

  /// Atualiza meta mensal
  Future<void> updateGoal(
    String id,
    double goal,
    GoalType goalType,
  ) async {
    try {
      AppLogger.debug('Updating client $id goal to $goal ($goalType)');

      await updateFields(id, {
        'monthlyGoal': goal,
        'goalType': goalType.name,
      });

      AppLogger.info('Client goal updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating client goal', e, stackTrace);
      rethrow;
    }
  }

  /// Estatísticas dos clientes
  Future<ClientStats> getStats(String userId) async {
    try {
      AppLogger.debug('Calculating client stats for user: $userId');

      final clients = await getByUserId(userId);

      final totalClients = clients.length;
      final activeClients = clients
          .where((c) => c.status == ClientStatus.active)
          .length;
      final onlineClients = clients
          .where((c) => c.type == ClientType.online)
          .length;
      final physicalClients = clients
          .where((c) => c.type == ClientType.physical)
          .length;
      final premiumClients = clients
          .where((c) => c.isPremium)
          .length;
      final totalGoal = clients
          .where((c) => c.monthlyGoal != null)
          .fold<double>(0, (total, c) => total + c.monthlyGoal!);

      return ClientStats(
        totalClients: totalClients,
        activeClients: activeClients,
        onlineClients: onlineClients,
        physicalClients: physicalClients,
        premiumClients: premiumClients,
        totalMonthlyGoal: totalGoal,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating client stats', e, stackTrace);
      rethrow;
    }
  }
}

// ============================================
// 📊 Client Statistics Model
// ============================================

class ClientStats {
  final int totalClients;
  final int activeClients;
  final int onlineClients;
  final int physicalClients;
  final int premiumClients;
  final double totalMonthlyGoal;

  ClientStats({
    required this.totalClients,
    required this.activeClients,
    required this.onlineClients,
    required this.physicalClients,
    required this.premiumClients,
    required this.totalMonthlyGoal,
  });

  double get activePercentage =>
      totalClients > 0 ? (activeClients / totalClients) * 100 : 0;

  double get onlinePercentage =>
      totalClients > 0 ? (onlineClients / totalClients) * 100 : 0;

  double get premiumPercentage =>
      totalClients > 0 ? (premiumClients / totalClients) * 100 : 0;
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  // TODO: Inject userId from auth
  return ClientRepository();
});
