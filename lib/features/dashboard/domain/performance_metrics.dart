import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceMetrics {
  final String id;
  final String clientId;
  final DateTime period;
  
  // Investimento
  final double investmentAmount;
  
  // Tráfego
  final int impressions;
  final int clicks;
  final double ctr; // Click-Through Rate (%)
  
  // Leads
  final int leads;
  final double cpl; // Custo Por Lead
  
  // Conversões
  final int conversions;
  final double conversionRate; // Taxa de Conversão (%)
  final double cpa; // Custo Por Aquisição
  
  // Receita
  final double revenue;
  final double aov; // Average Order Value
  
  // Performance
  final double roi; // Return on Investment (%)
  final double roas; // Return on Ad Spend
  final double ltv; // Lifetime Value
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const PerformanceMetrics({
    required this.id,
    required this.clientId,
    required this.period,
    required this.investmentAmount,
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.leads,
    required this.cpl,
    required this.conversions,
    required this.conversionRate,
    required this.cpa,
    required this.revenue,
    required this.aov,
    required this.roi,
    required this.roas,
    required this.ltv,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory PerformanceMetrics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerformanceMetrics(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      period: (data['period'] as Timestamp).toDate(),
      investmentAmount: (data['investmentAmount'] ?? 0).toDouble(),
      impressions: data['impressions'] ?? 0,
      clicks: data['clicks'] ?? 0,
      ctr: (data['ctr'] ?? 0).toDouble(),
      leads: data['leads'] ?? 0,
      cpl: (data['cpl'] ?? 0).toDouble(),
      conversions: data['conversions'] ?? 0,
      conversionRate: (data['conversionRate'] ?? 0).toDouble(),
      cpa: (data['cpa'] ?? 0).toDouble(),
      revenue: (data['revenue'] ?? 0).toDouble(),
      aov: (data['aov'] ?? 0).toDouble(),
      roi: (data['roi'] ?? 0).toDouble(),
      roas: (data['roas'] ?? 0).toDouble(),
      ltv: (data['ltv'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'period': Timestamp.fromDate(period),
      'investmentAmount': investmentAmount,
      'impressions': impressions,
      'clicks': clicks,
      'ctr': ctr,
      'leads': leads,
      'cpl': cpl,
      'conversions': conversions,
      'conversionRate': conversionRate,
      'cpa': cpa,
      'revenue': revenue,
      'aov': aov,
      'roi': roi,
      'roas': roas,
      'ltv': ltv,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
    };
  }

  PerformanceMetrics copyWith({
    String? id,
    String? clientId,
    DateTime? period,
    double? investmentAmount,
    int? impressions,
    int? clicks,
    double? ctr,
    int? leads,
    double? cpl,
    int? conversions,
    double? conversionRate,
    double? cpa,
    double? revenue,
    double? aov,
    double? roi,
    double? roas,
    double? ltv,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return PerformanceMetrics(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      period: period ?? this.period,
      investmentAmount: investmentAmount ?? this.investmentAmount,
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
      ctr: ctr ?? this.ctr,
      leads: leads ?? this.leads,
      cpl: cpl ?? this.cpl,
      conversions: conversions ?? this.conversions,
      conversionRate: conversionRate ?? this.conversionRate,
      cpa: cpa ?? this.cpa,
      revenue: revenue ?? this.revenue,
      aov: aov ?? this.aov,
      roi: roi ?? this.roi,
      roas: roas ?? this.roas,
      ltv: ltv ?? this.ltv,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Métodos de cálculo automático
  static double calculateCTR(int clicks, int impressions) {
    if (impressions == 0) return 0;
    return (clicks / impressions) * 100;
  }

  static double calculateCPL(double investment, int leads) {
    if (leads == 0) return 0;
    return investment / leads;
  }

  static double calculateCPA(double investment, int conversions) {
    if (conversions == 0) return 0;
    return investment / conversions;
  }

  static double calculateConversionRate(int conversions, int clicks) {
    if (clicks == 0) return 0;
    return (conversions / clicks) * 100;
  }

  static double calculateAOV(double revenue, int conversions) {
    if (conversions == 0) return 0;
    return revenue / conversions;
  }

  static double calculateROI(double revenue, double investment) {
    if (investment == 0) return 0;
    return ((revenue - investment) / investment) * 100;
  }

  static double calculateROAS(double revenue, double investment) {
    if (investment == 0) return 0;
    return revenue / investment;
  }

  static double calculateLTV(double aov, int avgPurchases) {
    return aov * avgPurchases;
  }
}
