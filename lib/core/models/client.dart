import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String? id;
  final String name;
  final ClientType type;
  final String? userId;
  final String? segment;
  final double? monthlyGoal;
  final GoalType? goalType;
  final PlanType? plan;
  final List<ClientContact>? contacts;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.id,
    required this.name,
    required this.type,
    this.userId,
    this.segment,
    this.monthlyGoal,
    this.goalType,
    this.plan,
    this.contacts,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
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
          ? GoalType.values.firstWhere((e) => e.name == data['goalType'])
          : null,
      plan: data['plan'] != null
          ? PlanType.values.firstWhere((e) => e.name == data['plan'])
          : null,
      contacts: (data['contacts'] as List?)
          ?.map((c) => ClientContact.fromMap(c))
          .toList(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'userId': userId,
      'segment': segment,
      'monthlyGoal': monthlyGoal,
      'goalType': goalType?.name,
      'plan': plan?.name,
      'contacts': contacts?.map((c) => c.toMap()).toList(),
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ClientContact {
  final String name;
  final String? email;
  final String? phone;
  final String? role;

  ClientContact({
    required this.name,
    this.email,
    this.phone,
    this.role,
  });

  factory ClientContact.fromMap(Map<String, dynamic> map) {
    return ClientContact(
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

enum ClientType { physical, online, hybrid }
enum GoalType { leads, revenue }
enum PlanType { basic, pro, enterprise }
