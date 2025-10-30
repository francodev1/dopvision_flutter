import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../models/client.dart';
import '../models/sale.dart';
import '../models/campaign.dart';

/// Simple Hive-backed cache service.
/// Stores JSON-serializable Maps for domain objects to avoid writing TypeAdapters
class CacheService {
  final _logger = Logger();
  final _uuid = const Uuid();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox('clients');
    await Hive.openBox('sales');
    await Hive.openBox('campaigns');
    await Hive.openBox('pending_changes');
    _initialized = true;
    _logger.i('CacheService initialized, boxes opened');
  }

  // ----------------- CLIENTS -----------------
  Future<String> saveClient(Client client, {String? id, bool markPending = true}) async {
    await init();
    final box = Hive.box('clients');
    final key = id ?? client.id ?? _uuid.v4();
    final map = _clientToMap(client);
    await box.put(key, map);
    if (markPending) await _addPendingChange(collection: 'clients', id: key, operation: 'upsert', data: map);
    return key;
  }

  Future<Client?> getClient(String id) async {
    await init();
    final box = Hive.box('clients');
    final map = box.get(id) as Map?;
    if (map == null) return null;
    return _mapToClient(Map<String, dynamic>.from(map));
  }

  Future<List<Client>> listClients() async {
    await init();
    final box = Hive.box('clients');
    return box.values
        .whereType<Map>()
        .map((m) => _mapToClient(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> deleteClient(String id, {bool markPending = true}) async {
    await init();
    final box = Hive.box('clients');
    await box.delete(id);
    if (markPending) await _addPendingChange(collection: 'clients', id: id, operation: 'delete', data: null);
  }

  // ----------------- SALES -----------------
  Future<String> saveSale(Sale sale, {String? id, bool markPending = true}) async {
    await init();
    final box = Hive.box('sales');
    final key = id ?? sale.id ?? _uuid.v4();
    final map = _saleToMap(sale);
    await box.put(key, map);
    if (markPending) await _addPendingChange(collection: 'sales', id: key, operation: 'upsert', data: map);
    return key;
  }

  Future<Sale?> getSale(String id) async {
    await init();
    final box = Hive.box('sales');
    final map = box.get(id) as Map?;
    if (map == null) return null;
    return _mapToSale(Map<String, dynamic>.from(map));
  }

  Future<List<Sale>> listSales() async {
    await init();
    final box = Hive.box('sales');
    return box.values
        .whereType<Map>()
        .map((m) => _mapToSale(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> deleteSale(String id, {bool markPending = true}) async {
    await init();
    final box = Hive.box('sales');
    await box.delete(id);
    if (markPending) await _addPendingChange(collection: 'sales', id: id, operation: 'delete', data: null);
  }

  // ----------------- CAMPAIGNS -----------------
  Future<String> saveCampaign(Campaign campaign, {String? id, bool markPending = true}) async {
    await init();
    final box = Hive.box('campaigns');
    final key = id ?? campaign.id ?? _uuid.v4();
    final map = _campaignToMap(campaign);
    await box.put(key, map);
    if (markPending) await _addPendingChange(collection: 'campaigns', id: key, operation: 'upsert', data: map);
    return key;
  }

  Future<Campaign?> getCampaign(String id) async {
    await init();
    final box = Hive.box('campaigns');
    final map = box.get(id) as Map?;
    if (map == null) return null;
    return _mapToCampaign(Map<String, dynamic>.from(map));
  }

  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    await init();
    final box = Hive.box('pending_changes');
    return box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<void> clearPendingChange(String key) async {
    await init();
    final box = Hive.box('pending_changes');
    await box.delete(key);
  }

  // ----------------- Pending tracking -----------------
  Future<String> _addPendingChange({required String collection, required String id, required String operation, Map<String, dynamic>? data}) async {
    await init();
    final box = Hive.box('pending_changes');
    final key = _uuid.v4();
    final entry = {
      'id': id,
      'collection': collection,
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'attempts': 0,
    };
    await box.put(key, entry);
    _logger.d('Pending change added: $key -> $entry');
    return key;
  }

  // ----------------- Converters -----------------
  Map<String, dynamic> _clientToMap(Client c) {
    return {
      'id': c.id,
      'name': c.name,
      'type': c.type.name,
      'userId': c.userId,
      'segment': c.segment,
      'monthlyGoal': c.monthlyGoal,
      'goalType': c.goalType?.name,
      'plan': c.plan?.name,
      'contacts': c.contacts?.map((ct) => ct.toMap()).toList(),
      'notes': c.notes,
      'createdAt': c.createdAt?.toIso8601String(),
      'updatedAt': c.updatedAt?.toIso8601String(),
    };
  }

  Client _mapToClient(Map<String, dynamic> m) {
    return Client(
      id: m['id'] as String?,
      name: m['name'] ?? '',
      type: ClientType.values.firstWhere((e) => e.name == (m['type'] ?? ''), orElse: () => ClientType.online),
      userId: m['userId'],
      segment: m['segment'],
      monthlyGoal: (m['monthlyGoal'] as num?)?.toDouble(),
      goalType: m['goalType'] != null ? GoalType.values.firstWhere((e) => e.name == m['goalType']) : null,
      plan: m['plan'] != null ? PlanType.values.firstWhere((e) => e.name == m['plan']) : null,
      contacts: (m['contacts'] as List?)?.map((c) => ClientContact.fromMap(Map<String, dynamic>.from(c))).toList(),
      notes: m['notes'],
      createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : null,
      updatedAt: m['updatedAt'] != null ? DateTime.parse(m['updatedAt']) : null,
    );
  }

  Map<String, dynamic> _saleToMap(Sale s) {
    return {
      'id': s.id,
      'amount': s.amount,
      'source': s.source,
      'date': s.date.toIso8601String(),
      'clientId': s.clientId,
      'productName': s.productName,
      'customer': s.customer,
    };
  }

  Sale _mapToSale(Map<String, dynamic> m) {
    return Sale(
      id: m['id'] as String?,
      amount: (m['amount'] ?? 0).toDouble(),
      source: m['source'] ?? '',
      date: m['date'] != null ? DateTime.parse(m['date']) : DateTime.now(),
      clientId: m['clientId'],
      productName: m['productName'],
      customer: m['customer'],
    );
  }

  Map<String, dynamic> _campaignToMap(Campaign c) {
    return {
      'id': c.id,
      'name': c.name,
      'clientId': c.clientId,
      'budget': c.budget,
      'startDate': c.startDate?.toIso8601String(),
      'endDate': c.endDate?.toIso8601String(),
      'status': c.status.name,
      'objective': c.objective.name,
      'platform': c.platform.name,
      'targetAudience': c.targetAudience,
      'creatives': c.creatives?.map((cr) => cr.toMap()).toList(),
      'metrics': c.metrics?.toMap(),
    };
  }

  Campaign _mapToCampaign(Map<String, dynamic> m) {
    return Campaign(
      id: m['id'] as String?,
      name: m['name'] ?? '',
      clientId: m['clientId'] ?? '',
      budget: (m['budget'] ?? 0).toDouble(),
      startDate: m['startDate'] != null ? DateTime.parse(m['startDate']) : null,
      endDate: m['endDate'] != null ? DateTime.parse(m['endDate']) : null,
      status: CampaignStatus.values.firstWhere((e) => e.name == (m['status'] ?? ''), orElse: () => CampaignStatus.testing),
      objective: CampaignObjective.values.firstWhere((e) => e.name == (m['objective'] ?? ''), orElse: () => CampaignObjective.leads),
      platform: Platform.values.firstWhere((e) => e.name == (m['platform'] ?? ''), orElse: () => Platform.facebook),
      targetAudience: m['targetAudience'],
      creatives: (m['creatives'] as List?)?.map((c) => Creative.fromMap(Map<String, dynamic>.from(c))).toList(),
      metrics: m['metrics'] != null ? CampaignMetrics.fromMap(Map<String, dynamic>.from(m['metrics'])) : null,
    );
  }
}
