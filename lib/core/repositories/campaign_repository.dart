// lib/core/repositories/campaign_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign_model.dart';
import 'base_repository.dart';
import '../utils/logger.dart';

/// 📢 Campaign Repository
class CampaignRepository extends BaseRepository<CampaignModel> {
  @override
  String get collectionName => 'campaigns';

  @override
  CampaignModel fromFirestore(DocumentSnapshot doc) {
    return CampaignModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(CampaignModel model) {
    return model.toFirestore();
  }

  // ============================================
  // 📋 Métodos Específicos de Campanha
  // ============================================

  /// Busca campanhas por cliente
  Future<List<CampaignModel>> getByClientId(
    String clientId, {
    CampaignStatus? status,
  }) async {
    try {
      AppLogger.debug('Fetching campaigns for client: $clientId');

      Query query = collection
          .where('clientId', isEqualTo: clientId)
          .where('isDeleted', isEqualTo: false);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching campaigns', e, stackTrace);
      rethrow;
    }
  }

  /// Stream de campanhas por cliente
  Stream<List<CampaignModel>> watchByClientId(
    String clientId, {
    CampaignStatus? status,
  }) {
    try {
      Query query = collection
          .where('clientId', isEqualTo: clientId)
          .where('isDeleted', isEqualTo: false);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error watching campaigns', e, stackTrace);
      rethrow;
    }
  }

  /// Busca campanhas por usuário
  Future<List<CampaignModel>> getByUserId(String userId) async {
    try {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user campaigns', e, stackTrace);
      rethrow;
    }
  }

  /// Busca campanhas ativas
  Future<List<CampaignModel>> getActive(String userId) async {
    try {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: CampaignStatus.active.name)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching active campaigns', e, stackTrace);
      rethrow;
    }
  }

  /// Busca campanhas por plataforma
  Future<List<CampaignModel>> getByPlatform(
    String userId,
    CampaignPlatform platform,
  ) async {
    try {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('platform', isEqualTo: platform.name)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching campaigns by platform', e, stackTrace);
      rethrow;
    }
  }

  /// Atualiza status da campanha
  Future<void> updateStatus(String id, CampaignStatus status) async {
    try {
      await updateFields(id, {'status': status.name});
      AppLogger.info('Campaign $id status updated to $status');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating campaign status', e, stackTrace);
      rethrow;
    }
  }

  /// Atualiza métricas da campanha
  Future<void> updateMetrics(String id, CampaignMetrics metrics) async {
    try {
      await updateFields(id, {'metrics': metrics.toJson()});
      AppLogger.info('Campaign $id metrics updated');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating campaign metrics', e, stackTrace);
      rethrow;
    }
  }

  /// Estatísticas das campanhas
  Future<CampaignStats> getStats(String userId) async {
    try {
      final campaigns = await getByUserId(userId);

      final totalCampaigns = campaigns.length;
      final activeCampaigns = campaigns
          .where((c) => c.status == CampaignStatus.active)
          .length;

      final totalSpent = campaigns.fold<double>(
        0,
        (total, c) => total + (c.metrics?.spent ?? 0),
      );

      final totalRevenue = campaigns.fold<double>(
        0,
        (total, c) => total + (c.metrics?.revenue ?? 0),
      );

      final totalConversions = campaigns.fold<int>(
        0,
        (total, c) => total + (c.metrics?.conversions ?? 0),
      );

      final totalClicks = campaigns.fold<int>(
        0,
        (total, c) => total + (c.metrics?.clicks ?? 0),
      );

      final totalImpressions = campaigns.fold<int>(
        0,
        (total, c) => total + (c.metrics?.impressions ?? 0),
      );

      return CampaignStats(
        totalCampaigns: totalCampaigns,
        activeCampaigns: activeCampaigns,
        totalSpent: totalSpent,
        totalRevenue: totalRevenue,
        totalConversions: totalConversions,
        totalClicks: totalClicks,
        totalImpressions: totalImpressions,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating campaign stats', e, stackTrace);
      rethrow;
    }
  }
}

// ============================================
// 📊 Campaign Statistics
// ============================================

class CampaignStats {
  final int totalCampaigns;
  final int activeCampaigns;
  final double totalSpent;
  final double totalRevenue;
  final int totalConversions;
  final int totalClicks;
  final int totalImpressions;

  CampaignStats({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.totalSpent,
    required this.totalRevenue,
    required this.totalConversions,
    required this.totalClicks,
    required this.totalImpressions,
  });

  double get roi {
    if (totalSpent == 0) return 0;
    return ((totalRevenue - totalSpent) / totalSpent) * 100;
  }

  double get averageCtr {
    if (totalImpressions == 0) return 0;
    return (totalClicks / totalImpressions) * 100;
  }

  double get averageCpa {
    if (totalConversions == 0) return 0;
    return totalSpent / totalConversions;
  }
}

// ============================================
// 🎯 Provider
// ============================================

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository();
});
