// lib/core/models/campaign_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 📢 Model de Campanha
class CampaignModel {
  final String? id;
  final String clientId;
  final String userId;
  final String name;
  final CampaignPlatform platform;
  final CampaignStatus status;
  final CampaignType type;
  final String? objective;
  final double? budget;
  final double? dailyBudget;
  final DateTime? startDate;
  final DateTime? endDate;
  final CampaignMetrics? metrics;
  final CampaignAudience? audience;
  final CampaignCreative? creative;
  final List<String> tags;
  final String? notes;
  final String? externalId;
  final SyncData? syncData;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  const CampaignModel({
    this.id,
    required this.clientId,
    required this.userId,
    required this.name,
    required this.platform,
    required this.status,
    required this.type,
    this.objective,
    this.budget,
    this.dailyBudget,
    this.startDate,
    this.endDate,
    this.metrics,
    this.audience,
    this.creative,
    this.tags = const [],
    this.notes,
    this.externalId,
    this.syncData,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
  });

  factory CampaignModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CampaignModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      platform: CampaignPlatform.values.firstWhere(
        (e) => e.name == data['platform'],
        orElse: () => CampaignPlatform.facebook,
      ),
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CampaignStatus.draft,
      ),
      type: CampaignType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CampaignType.traffic,
      ),
      objective: data['objective'],
      budget: data['budget']?.toDouble(),
      dailyBudget: data['dailyBudget']?.toDouble(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      metrics: data['metrics'] != null
          ? CampaignMetrics.fromJson(data['metrics'])
          : null,
      audience: data['audience'] != null
          ? CampaignAudience.fromJson(data['audience'])
          : null,
      creative: data['creative'] != null
          ? CampaignCreative.fromJson(data['creative'])
          : null,
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
      notes: data['notes'],
      externalId: data['externalId'],
      syncData: data['syncData'] != null
          ? SyncData.fromJson(data['syncData'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'userId': userId,
      'name': name,
      'platform': platform.name,
      'status': status.name,
      'type': type.name,
      'objective': objective,
      'budget': budget,
      'dailyBudget': dailyBudget,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'metrics': metrics?.toJson(),
      'audience': audience?.toJson(),
      'creative': creative?.toJson(),
      'tags': tags,
      'notes': notes,
      'externalId': externalId,
      'syncData': syncData?.toJson(),
      'isDeleted': isDeleted,
    };
  }

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String?,
      clientId: json['clientId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      platform: CampaignPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => CampaignPlatform.facebook,
      ),
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CampaignStatus.draft,
      ),
      type: CampaignType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CampaignType.traffic,
      ),
      objective: json['objective'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      dailyBudget: (json['dailyBudget'] as num?)?.toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      metrics: json['metrics'] != null
          ? CampaignMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      audience: json['audience'] != null
          ? CampaignAudience.fromJson(json['audience'] as Map<String, dynamic>)
          : null,
      creative: json['creative'] != null
          ? CampaignCreative.fromJson(json['creative'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      externalId: json['externalId'] as String?,
      syncData: json['syncData'] != null
          ? SyncData.fromJson(json['syncData'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'userId': userId,
      'name': name,
      'platform': platform.name,
      'status': status.name,
      'type': type.name,
      'objective': objective,
      'budget': budget,
      'dailyBudget': dailyBudget,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'metrics': metrics?.toJson(),
      'audience': audience?.toJson(),
      'creative': creative?.toJson(),
      'tags': tags,
      'notes': notes,
      'externalId': externalId,
      'syncData': syncData?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}

// ============================================
// 🔧 Extensions
// ============================================

extension CampaignModelX on CampaignModel {
  // Getters computados
  bool get isActive => status == CampaignStatus.active;
  bool get isPaused => status == CampaignStatus.paused;
  bool get isCompleted => status == CampaignStatus.completed;
  bool get isRunning => isActive && !isDeleted;

  double get roi {
    if (metrics == null || budget == null || budget == 0) return 0;
    return ((metrics!.revenue - budget!) / budget!) * 100;
  }

  double get cpa {
    if (metrics == null || metrics!.conversions == 0) return 0;
    return metrics!.spent / metrics!.conversions;
  }

  double get ctr {
    if (metrics == null || metrics!.impressions == 0) return 0;
    return (metrics!.clicks / metrics!.impressions) * 100;
  }

  double get conversionRate {
    if (metrics == null || metrics!.clicks == 0) return 0;
    return (metrics!.conversions / metrics!.clicks) * 100;
  }

  int get daysRunning {
    if (startDate == null) return 0;
    final end = endDate ?? DateTime.now();
    return end.difference(startDate!).inDays;
  }

  double get budgetUsedPercentage {
    if (budget == null || budget == 0 || metrics == null) return 0;
    return (metrics!.spent / budget!) * 100;
  }
}

// ============================================
// 📋 Enums
// ============================================

enum CampaignPlatform {
  facebook('Facebook'),
  instagram('Instagram'),
  google('Google Ads'),
  tiktok('TikTok'),
  linkedin('LinkedIn'),
  twitter('Twitter/X'),
  youtube('YouTube');

  final String displayName;
  const CampaignPlatform(this.displayName);
}

enum CampaignStatus {
  draft('Rascunho'),
  active('Ativa'),
  paused('Pausada'),
  completed('Concluída'),
  archived('Arquivada');

  final String displayName;
  const CampaignStatus(this.displayName);
}

enum CampaignType {
  traffic('Tráfego'),
  conversions('Conversões'),
  leads('Leads'),
  engagement('Engajamento'),
  awareness('Reconhecimento'),
  sales('Vendas');

  final String displayName;
  const CampaignType(this.displayName);
}

// ============================================
// 📊 Métricas da Campanha
// ============================================

class CampaignMetrics {
  final int impressions;
  final int clicks;
  final int conversions;
  final int leads;
  final double spent;
  final double revenue;
  final int reach;
  final int engagement;

  const CampaignMetrics({
    this.impressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.leads = 0,
    this.spent = 0.0,
    this.revenue = 0.0,
    this.reach = 0,
    this.engagement = 0,
  });

  factory CampaignMetrics.fromJson(Map<String, dynamic> json) {
    return CampaignMetrics(
      impressions: json['impressions'] as int? ?? 0,
      clicks: json['clicks'] as int? ?? 0,
      conversions: json['conversions'] as int? ?? 0,
      leads: json['leads'] as int? ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      reach: json['reach'] as int? ?? 0,
      engagement: json['engagement'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'conversions': conversions,
      'leads': leads,
      'spent': spent,
      'revenue': revenue,
      'reach': reach,
      'engagement': engagement,
    };
  }
}

// ============================================
// 🎯 Público-alvo
// ============================================

class CampaignAudience {
  final String? ageMin;
  final String? ageMax;
  final List<String> genders;
  final List<String> locations;
  final List<String> interests;
  final List<String> behaviors;

  const CampaignAudience({
    this.ageMin,
    this.ageMax,
    this.genders = const [],
    this.locations = const [],
    this.interests = const [],
    this.behaviors = const [],
  });

  factory CampaignAudience.fromJson(Map<String, dynamic> json) {
    return CampaignAudience(
      ageMin: json['ageMin'] as String?,
      ageMax: json['ageMax'] as String?,
      genders: (json['genders'] as List?)?.cast<String>() ?? [],
      locations: (json['locations'] as List?)?.cast<String>() ?? [],
      interests: (json['interests'] as List?)?.cast<String>() ?? [],
      behaviors: (json['behaviors'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageMin': ageMin,
      'ageMax': ageMax,
      'genders': genders,
      'locations': locations,
      'interests': interests,
      'behaviors': behaviors,
    };
  }
}

// ============================================
// 🎨 Criativos da Campanha
// ============================================

class CampaignCreative {
  final String? headline;
  final String? description;
  final String? ctaText;
  final List<String> imageUrls;
  final String? videoUrl;

  const CampaignCreative({
    this.headline,
    this.description,
    this.ctaText,
    this.imageUrls = const [],
    this.videoUrl,
  });

  factory CampaignCreative.fromJson(Map<String, dynamic> json) {
    return CampaignCreative(
      headline: json['headline'] as String?,
      description: json['description'] as String?,
      ctaText: json['ctaText'] as String?,
      imageUrls: (json['imageUrls'] as List?)?.cast<String>() ?? [],
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'description': description,
      'ctaText': ctaText,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
    };
  }
}

// ============================================
// 🔄 Dados de Sincronização
// ============================================

class SyncData {
  final DateTime? lastSyncAt;
  final bool isSyncing;
  final String? syncError;
  final int syncRetries;

  const SyncData({
    this.lastSyncAt,
    this.isSyncing = false,
    this.syncError,
    this.syncRetries = 0,
  });

  factory SyncData.fromJson(Map<String, dynamic> json) {
    return SyncData(
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      isSyncing: json['isSyncing'] as bool? ?? false,
      syncError: json['syncError'] as String?,
      syncRetries: json['syncRetries'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'isSyncing': isSyncing,
      'syncError': syncError,
      'syncRetries': syncRetries,
    };
  }
}
