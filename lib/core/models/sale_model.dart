// lib/core/models/sale_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 💰 Model de Venda
class SaleModel {
  final String? id;
  final String clientId;
  final String userId;
  final String? campaignId;
  final double amount;
  final SaleStatus status;
  final DateTime date;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? productName;
  final int? quantity;
  final String? paymentMethod;
  final String? transactionId;
  final String? notes;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  const SaleModel({
    this.id,
    required this.clientId,
    required this.userId,
    this.campaignId,
    required this.amount,
    required this.status,
    required this.date,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.productName,
    this.quantity,
    this.paymentMethod,
    this.transactionId,
    this.notes,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      userId: data['userId'] ?? '',
      campaignId: data['campaignId'],
      amount: data['amount']?.toDouble() ?? 0.0,
      status: SaleStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SaleStatus.pending,
      ),
      date: (data['date'] as Timestamp).toDate(),
      customerName: data['customerName'],
      customerEmail: data['customerEmail'],
      customerPhone: data['customerPhone'],
      productName: data['productName'],
      quantity: data['quantity'],
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      notes: data['notes'],
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
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
      'campaignId': campaignId,
      'amount': amount,
      'status': status.name,
      'date': Timestamp.fromDate(date),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'productName': productName,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'notes': notes,
      'tags': tags,
      'isDeleted': isDeleted,
    };
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String?,
      clientId: json['clientId'] as String,
      userId: json['userId'] as String,
      campaignId: json['campaignId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: SaleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SaleStatus.pending,
      ),
      date: DateTime.parse(json['date'] as String),
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      productName: json['productName'] as String?,
      quantity: json['quantity'] as int?,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
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
      'campaignId': campaignId,
      'amount': amount,
      'status': status.name,
      'date': date.toIso8601String(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'productName': productName,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}

enum SaleStatus {
  pending('Pendente'),
  approved('Aprovada'),
  cancelled('Cancelada'),
  refunded('Reembolsada');

  final String displayName;
  const SaleStatus(this.displayName);
}
