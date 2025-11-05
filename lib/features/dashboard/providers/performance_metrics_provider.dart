import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/performance_metrics_repository.dart';
import '../domain/performance_metrics.dart';

// Provider para métricas de um cliente específico
final clientMetricsProvider = StreamProvider.family<List<PerformanceMetrics>, String>((ref, clientId) {
  return ref.watch(performanceMetricsRepositoryProvider).getClientMetrics(clientId);
});

// Provider para última métrica de um cliente
final latestClientMetricsProvider = FutureProvider.family<PerformanceMetrics?, String>((ref, clientId) {
  return ref.watch(performanceMetricsRepositoryProvider).getLatestMetrics(clientId);
});
