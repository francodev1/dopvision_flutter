// lib/core/repositories/sale_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale_model.dart';
import 'base_repository.dart';
import '../utils/logger.dart';

/// 💰 Sale Repository
class SaleRepository extends BaseRepository<SaleModel> {
  @override
  String get collectionName => 'sales';

  @override
  SaleModel fromFirestore(DocumentSnapshot doc) {
    return SaleModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(SaleModel model) {
    return model.toFirestore();
  }

  /// Busca vendas por cliente
  Future<List<SaleModel>> getByClientId(String clientId) async {
    try {
      final snapshot = await collection
          .where('clientId', isEqualTo: clientId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching sales', e, stackTrace);
      rethrow;
    }
  }

  /// Busca vendas por campanha
  Future<List<SaleModel>> getByCampaignId(String campaignId) async {
    try {
      final snapshot = await collection
          .where('campaignId', isEqualTo: campaignId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching campaign sales', e, stackTrace);
      rethrow;
    }
  }

  /// Busca vendas por período
  Future<List<SaleModel>> getByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .where('isDeleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching sales by date range', e, stackTrace);
      rethrow;
    }
  }

  /// Estatísticas de vendas
  Future<SaleStats> getStats(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = collection
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final sales = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

      final totalSales = sales.length;
      final totalRevenue = sales.fold<double>(0, (total, s) => total + s.amount);
      final approvedSales = sales.where((s) => s.status == SaleStatus.approved).length;
      final pendingSales = sales.where((s) => s.status == SaleStatus.pending).length;

      return SaleStats(
        totalSales: totalSales,
        totalRevenue: totalRevenue,
        approvedSales: approvedSales,
        pendingSales: pendingSales,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating sale stats', e, stackTrace);
      rethrow;
    }
  }
}

class SaleStats {
  final int totalSales;
  final double totalRevenue;
  final int approvedSales;
  final int pendingSales;

  SaleStats({
    required this.totalSales,
    required this.totalRevenue,
    required this.approvedSales,
    required this.pendingSales,
  });

  double get averageTicket => totalSales > 0 ? totalRevenue / totalSales : 0;
  double get approvalRate => totalSales > 0 ? (approvedSales / totalSales) * 100 : 0;
}

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository();
});
