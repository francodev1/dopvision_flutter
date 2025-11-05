import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/base_repository.dart';
import '../domain/performance_metrics.dart';

final performanceMetricsRepositoryProvider = Provider<PerformanceMetricsRepository>((ref) {
  return PerformanceMetricsRepository();
});

class PerformanceMetricsRepository extends BaseRepository<PerformanceMetrics> {
  @override
  String get collectionName => 'performance_metrics';

  @override
  PerformanceMetrics fromFirestore(DocumentSnapshot doc) {
    return PerformanceMetrics.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(PerformanceMetrics item) {
    return item.toFirestore();
  }

  // Buscar métricas de um cliente específico
  Stream<List<PerformanceMetrics>> getClientMetrics(String clientId) {
    return collection
        .where('clientId', isEqualTo: clientId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('period', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(fromFirestore).toList());
  }

  // Buscar última métrica de um cliente
  Future<PerformanceMetrics?> getLatestMetrics(String clientId) async {
    final snapshot = await collection
        .where('clientId', isEqualTo: clientId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('period', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return fromFirestore(snapshot.docs.first);
  }

  // Criar métricas calculadas automaticamente
  Future<void> createCalculatedMetrics({
    required String clientId,
    required DateTime period,
    required double investmentAmount,
    required int impressions,
    required int clicks,
    required int leads,
    required int conversions,
    required double revenue,
    int avgPurchases = 1,
  }) async {
    final metrics = PerformanceMetrics(
      id: '',
      clientId: clientId,
      period: period,
      investmentAmount: investmentAmount,
      impressions: impressions,
      clicks: clicks,
      ctr: PerformanceMetrics.calculateCTR(clicks, impressions),
      leads: leads,
      cpl: PerformanceMetrics.calculateCPL(investmentAmount, leads),
      conversions: conversions,
      conversionRate: PerformanceMetrics.calculateConversionRate(conversions, clicks),
      cpa: PerformanceMetrics.calculateCPA(investmentAmount, conversions),
      revenue: revenue,
      aov: PerformanceMetrics.calculateAOV(revenue, conversions),
      roi: PerformanceMetrics.calculateROI(revenue, investmentAmount),
      roas: PerformanceMetrics.calculateROAS(revenue, investmentAmount),
      ltv: PerformanceMetrics.calculateLTV(
        PerformanceMetrics.calculateAOV(revenue, conversions),
        avgPurchases,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await create(metrics);
  }

  // Atualizar métricas e recalcular automaticamente
  Future<void> updateCalculatedMetrics({
    required String id,
    required String clientId,
    required DateTime period,
    required double investmentAmount,
    required int impressions,
    required int clicks,
    required int leads,
    required int conversions,
    required double revenue,
    int avgPurchases = 1,
  }) async {
    final metrics = PerformanceMetrics(
      id: id,
      clientId: clientId,
      period: period,
      investmentAmount: investmentAmount,
      impressions: impressions,
      clicks: clicks,
      ctr: PerformanceMetrics.calculateCTR(clicks, impressions),
      leads: leads,
      cpl: PerformanceMetrics.calculateCPL(investmentAmount, leads),
      conversions: conversions,
      conversionRate: PerformanceMetrics.calculateConversionRate(conversions, clicks),
      cpa: PerformanceMetrics.calculateCPA(investmentAmount, conversions),
      revenue: revenue,
      aov: PerformanceMetrics.calculateAOV(revenue, conversions),
      roi: PerformanceMetrics.calculateROI(revenue, investmentAmount),
      roas: PerformanceMetrics.calculateROAS(revenue, investmentAmount),
      ltv: PerformanceMetrics.calculateLTV(
        PerformanceMetrics.calculateAOV(revenue, conversions),
        avgPurchases,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await update(id, metrics);
  }
}
