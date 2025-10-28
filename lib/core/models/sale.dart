import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String? id;
  final double amount;
  final String source;
  final DateTime date;
  final String? clientId;
  final String? productName;
  final String? customer;

  Sale({
    this.id,
    required this.amount,
    required this.source,
    required this.date,
    this.clientId,
    this.productName,
    this.customer,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      source: data['source'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      clientId: data['clientId'],
      productName: data['productName'],
      customer: data['customer'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'source': source,
      'date': Timestamp.fromDate(date),
      'clientId': clientId,
      'productName': productName,
      'customer': customer,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
