// lib/core/models/client_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🏢 Model de Cliente
/// 
/// Representa um cliente no sistema DoPVision.
/// Suporta tanto clientes online quanto físicos.
class ClientModel {
  final String? id;
  final String name;
  final ClientType type;
  final String? userId;
  final String? segment;
  final double? monthlyGoal;
  final GoalType? goalType;
  final PlanType? plan;
  final ClientStatus status;
  final List<ClientContact> contacts;
  final String? notes;
  final List<String> tags;
  final ClientAddress? address;
  final ClientSocialMedia? socialMedia;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  const ClientModel({
    this.id,
    required this.name,
    required this.type,
    this.userId,
    this.segment,
    this.monthlyGoal,
    this.goalType,
    this.plan,
    this.status = ClientStatus.active,
    this.contacts = const [],
    this.notes,
    this.tags = const [],
    this.address,
    this.socialMedia,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
  });

  /// copyWith para imutabilidade
  ClientModel copyWith({
    String? id,
    String? name,
    ClientType? type,
    String? userId,
    String? segment,
    double? monthlyGoal,
    GoalType? goalType,
    PlanType? plan,
    ClientStatus? status,
    List<ClientContact>? contacts,
    String? notes,
    List<String>? tags,
    ClientAddress? address,
    ClientSocialMedia? socialMedia,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      segment: segment ?? this.segment,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      goalType: goalType ?? this.goalType,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      address: address ?? this.address,
      socialMedia: socialMedia ?? this.socialMedia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Factory para criar do Firestore
  factory ClientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ClientModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: ClientType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ClientType.online,
      ),
      userId: data['userId'],
      segment: data['segment'],
      monthlyGoal: data['monthlyGoal']?.toDouble(),
      goalType: data['goalType'] != null
          ? GoalType.values.firstWhere(
              (e) => e.name == data['goalType'],
              orElse: () => GoalType.sales,
            )
          : null,
      plan: data['plan'] != null
          ? PlanType.values.firstWhere(
              (e) => e.name == data['plan'],
              orElse: () => PlanType.free,
            )
          : null,
      status: data['status'] != null
          ? ClientStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => ClientStatus.active,
            )
          : ClientStatus.active,
      contacts: (data['contacts'] as List?)
              ?.map((e) => ClientContact.fromJson(e))
              .toList() ??
          [],
      notes: data['notes'],
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
      address: data['address'] != null
          ? ClientAddress.fromJson(data['address'])
          : null,
      socialMedia: data['socialMedia'] != null
          ? ClientSocialMedia.fromJson(data['socialMedia'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  /// Converte para Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'userId': userId,
      'segment': segment,
      'monthlyGoal': monthlyGoal,
      'goalType': goalType?.name,
      'plan': plan?.name,
      'status': status.name,
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'notes': notes,
      'tags': tags,
      'address': address?.toJson(),
      'socialMedia': socialMedia?.toJson(),
      'isDeleted': isDeleted,
    };
  }

  /// Factory do JSON
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: ClientType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ClientType.online,
      ),
      userId: json['userId'] as String?,
      segment: json['segment'] as String?,
      monthlyGoal: (json['monthlyGoal'] as num?)?.toDouble(),
      goalType: json['goalType'] != null
          ? GoalType.values.firstWhere(
              (e) => e.name == json['goalType'],
              orElse: () => GoalType.sales,
            )
          : null,
      plan: json['plan'] != null
          ? PlanType.values.firstWhere(
              (e) => e.name == json['plan'],
              orElse: () => PlanType.free,
            )
          : null,
      status: json['status'] != null
          ? ClientStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => ClientStatus.active,
            )
          : ClientStatus.active,
      contacts: (json['contacts'] as List?)
              ?.map((e) => ClientContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      address: json['address'] != null
          ? ClientAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      socialMedia: json['socialMedia'] != null
          ? ClientSocialMedia.fromJson(
              json['socialMedia'] as Map<String, dynamic>)
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

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'userId': userId,
      'segment': segment,
      'monthlyGoal': monthlyGoal,
      'goalType': goalType?.name,
      'plan': plan?.name,
      'status': status.name,
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'notes': notes,
      'tags': tags,
      'address': address?.toJson(),
      'socialMedia': socialMedia?.toJson(),
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

extension ClientModelX on ClientModel {
  /// Nome completo com tipo
  String get displayName => '$name (${type.displayName})';

  /// Progresso da meta (0.0 a 1.0)
  double getGoalProgress(double currentValue) {
    if (monthlyGoal == null || monthlyGoal == 0) return 0.0;
    return (currentValue / monthlyGoal!).clamp(0.0, 1.0);
  }

  /// Verificar se tem contato principal
  bool get hasMainContact => contacts.any((c) => c.isMain);

  /// Obter contato principal
  ClientContact? get mainContact =>
      contacts.isNotEmpty ? contacts.firstWhere((c) => c.isMain, orElse: () => contacts.first) : null;

  /// Verificar se está ativo
  bool get isActive => status == ClientStatus.active && !isDeleted;

  /// Verificar se é premium
  bool get isPremium =>
      plan == PlanType.professional || plan == PlanType.enterprise;
}

// ============================================
// 📋 Enums
// ============================================

/// Tipo do cliente
enum ClientType {
  online('Online'),
  physical('Físico');

  final String displayName;
  const ClientType(this.displayName);
}

/// Status do cliente
enum ClientStatus {
  active('Ativo'),
  inactive('Inativo'),
  pending('Pendente'),
  suspended('Suspenso');

  final String displayName;
  const ClientStatus(this.displayName);
}

/// Tipo de meta
enum GoalType {
  sales('Vendas'),
  leads('Leads'),
  revenue('Receita'),
  roi('ROI'),
  traffic('Tráfego');

  final String displayName;
  const GoalType(this.displayName);
}

/// Plano contratado
enum PlanType {
  free('Gratuito'),
  basic('Básico'),
  professional('Profissional'),
  enterprise('Enterprise');

  final String displayName;
  const PlanType(this.displayName);
}

// ============================================
// 📞 Contato do Cliente
// ============================================

class ClientContact {
  final String name;
  final String value;
  final ContactType type;
  final bool isMain;

  const ClientContact({
    required this.name,
    required this.value,
    required this.type,
    this.isMain = false,
  });

  factory ClientContact.fromJson(Map<String, dynamic> json) {
    return ClientContact(
      name: json['name'] as String,
      value: json['value'] as String,
      type: ContactType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContactType.email,
      ),
      isMain: json['isMain'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'type': type.name,
      'isMain': isMain,
    };
  }
}

enum ContactType {
  email('Email'),
  phone('Telefone'),
  whatsapp('WhatsApp'),
  telegram('Telegram');

  final String displayName;
  const ContactType(this.displayName);
}

// ============================================
// 📍 Endereço do Cliente
// ============================================

class ClientAddress {
  final String? street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  const ClientAddress({
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.country,
    this.zipCode,
  });

  factory ClientAddress.fromJson(Map<String, dynamic> json) {
    return ClientAddress(
      street: json['street'] as String?,
      number: json['number'] as String?,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
    };
  }
}

// ============================================
// 🌐 Redes Sociais do Cliente
// ============================================

class ClientSocialMedia {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;
  final String? youtube;
  final String? tiktok;

  const ClientSocialMedia({
    this.facebook,
    this.instagram,
    this.twitter,
    this.linkedin,
    this.youtube,
    this.tiktok,
  });

  factory ClientSocialMedia.fromJson(Map<String, dynamic> json) {
    return ClientSocialMedia(
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      linkedin: json['linkedin'] as String?,
      youtube: json['youtube'] as String?,
      tiktok: json['tiktok'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'linkedin': linkedin,
      'youtube': youtube,
      'tiktok': tiktok,
    };
  }
}
