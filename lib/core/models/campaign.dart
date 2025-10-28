import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String? id;
  final String name;
  final String clientId;
  final double budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final CampaignStatus status;
  final CampaignObjective objective;
  final Platform platform;
  final String? targetAudience;
  final List<Creative>? creatives;
  final CampaignMetrics? metrics;

  Campaign({
    this.id,
    required this.name,
    required this.clientId,
    required this.budget,
    this.startDate,
    this.endDate,
    this.status = CampaignStatus.testing,
    this.objective = CampaignObjective.leads,
    this.platform = Platform.facebook,
    this.targetAudience,
    this.creatives,
    this.metrics,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      name: data['name'] ?? '',
      clientId: data['clientId'] ?? '',
      budget: (data['budget'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CampaignStatus.testing,
      ),
      objective: CampaignObjective.values.firstWhere(
        (e) => e.name == data['objective'],
        orElse: () => CampaignObjective.leads,
      ),
      platform: Platform.values.firstWhere(
        (e) => e.name == data['platform'],
        orElse: () => Platform.facebook,
      ),
      targetAudience: data['targetAudience'],
      creatives: (data['creatives'] as List?)
          ?.map((c) => Creative.fromMap(c))
          .toList(),
      metrics: data['metrics'] != null
          ? CampaignMetrics.fromMap(data['metrics'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'clientId': clientId,
      'budget': budget,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status.name,
      'objective': objective.name,
      'platform': platform.name,
      'targetAudience': targetAudience,
      'creatives': creatives?.map((c) => c.toMap()).toList(),
      'metrics': metrics?.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class Creative {
  final String name;
  final CreativeType type;
  final String? url;
  final double? performance;

  Creative({
    required this.name,
    required this.type,
    this.url,
    this.performance,
  });

  factory Creative.fromMap(Map<String, dynamic> map) {
    return Creative(
      name: map['name'] ?? '',
      type: CreativeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CreativeType.image,
      ),
      url: map['url'],
      performance: map['performance']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'url': url,
      'performance': performance,
    };
  }
}

class CampaignMetrics {
  final int impressions;
  final int clicks;
  final int conversions;
  final double ctr;
  final double cpc;
  final double cpa;
  final double roas;
  final double cpm;
  final int leads;

  CampaignMetrics({
    this.impressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.ctr = 0.0,
    this.cpc = 0.0,
    this.cpa = 0.0,
    this.roas = 0.0,
    this.cpm = 0.0,
    this.leads = 0,
  });

  factory CampaignMetrics.fromMap(Map<String, dynamic> map) {
    return CampaignMetrics(
      impressions: map['impressions'] ?? 0,
      clicks: map['clicks'] ?? 0,
      conversions: map['conversions'] ?? 0,
      ctr: (map['ctr'] ?? 0).toDouble(),
      cpc: (map['cpc'] ?? 0).toDouble(),
      cpa: (map['cpa'] ?? 0).toDouble(),
      roas: (map['roas'] ?? 0).toDouble(),
      cpm: (map['cpm'] ?? 0).toDouble(),
      leads: map['leads'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'conversions': conversions,
      'ctr': ctr,
      'cpc': cpc,
      'cpa': cpa,
      'roas': roas,
      'cpm': cpm,
      'leads': leads,
    };
  }
}

enum CampaignStatus { active, paused, testing, completed }
enum CampaignObjective { leads, sales, remarketing, awareness }
enum Platform { facebook, google, tiktok, linkedin, other }
enum CreativeType { image, video, carousel }
