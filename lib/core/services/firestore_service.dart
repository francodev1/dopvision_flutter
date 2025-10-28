import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../models/campaign.dart';
import '../models/sale.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== CLIENTS ==========
  
  Stream<List<Client>> getClients(String userId) {
    return _db
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList());
  }

  Future<void> addClient(Client client) async {
    await _db.collection('clients').add(client.toFirestore());
  }

  Future<void> updateClient(String id, Client client) async {
    await _db.collection('clients').doc(id).update(client.toFirestore());
  }

  Future<void> deleteClient(String id) async {
    await _db.collection('clients').doc(id).delete();
  }

  // ========== CAMPAIGNS ==========

  Stream<List<Campaign>> getCampaigns(String clientId) {
    return _db
        .collection('campaigns')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList());
  }

  Future<void> addCampaign(Campaign campaign) async {
    await _db.collection('campaigns').add(campaign.toFirestore());
  }

  Future<void> updateCampaign(String id, Campaign campaign) async {
    await _db.collection('campaigns').doc(id).update(campaign.toFirestore());
  }

  Future<void> deleteCampaign(String id) async {
    await _db.collection('campaigns').doc(id).delete();
  }

  // ========== SALES ==========

  Stream<List<Sale>> getSales(String clientId) {
    return _db
        .collection('sales')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  Future<void> addSale(Sale sale) async {
    await _db.collection('sales').add(sale.toFirestore());
  }

  Future<void> deleteSale(String id) async {
    await _db.collection('sales').doc(id).delete();
  }
}
