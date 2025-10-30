import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

import 'cache_service.dart';

class SyncService {
  final CacheService cacheService;
  final _logger = Logger();
  Timer? _pollTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isRunning = false;

  SyncService({required this.cacheService});

  Future<void> init() async {
    await cacheService.init();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _logger.i('Connectivity restored, triggering sync');
        triggerSync();
      }
    });
    _startPeriodic();
  }

  void _startPeriodic() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => triggerSync());
  }

  Future<void> dispose() async {
    _pollTimer?.cancel();
    await _connectivitySub?.cancel();
  }

  Future<void> triggerSync() async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      final pending = await cacheService.getPendingChanges();
      if (pending.isEmpty) return;
      _logger.i('Found ${pending.length} pending changes, processing...');
      for (var entry in pending) {
        await _processEntry(entry);
      }
    } catch (e, st) {
      _logger.e('Sync error: $e', error: e, stackTrace: st);
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processEntry(Map<String, dynamic> entry) async {
    // In our implementation, we stored entries with auto-generated keys inside Hive; however
    // the CacheService returns a list of maps without the hive key. We'll rely on id+collection to match.
    final collection = entry['collection'] as String? ?? '';
    final id = entry['id'] as String?;
    final operation = entry['operation'] as String? ?? 'upsert';
    final data = entry['data'] as Map<String, dynamic>?;

    try {
      final firestore = FirebaseFirestore.instance;
      if (operation == 'delete') {
        await firestore.collection(collection).doc(id).delete();
        _logger.i('Deleted remote $collection/$id');
      } else {
        // upsert
        if (data == null) throw Exception('No data for upsert');
        final sanitized = Map<String, dynamic>.from(data);
        // Convert ISO date strings back to Timestamps when possible
        sanitized.updateAll((k, v) {
          if (v is String) {
            final d = DateTime.tryParse(v);
            if (d != null) return Timestamp.fromDate(d);
          }
          return v;
        });
        await firestore.collection(collection).doc(id).set(sanitized, SetOptions(merge: true));
        _logger.i('Upserted remote $collection/$id');
      }
      // clear pending - find matching pending by id+collection
      final pending = await cacheService.getPendingChanges();
      for (var p in pending) {
        if (p['id'] == id && p['collection'] == collection) {
          // ideally we'd remove by hive key but our list lacks it; CacheService exposes clear by id
          await cacheService.clearPendingChange(p['id'].toString());
        }
      }
    } catch (e, st) {
      _logger.w('Failed to sync entry $collection/$id: $e', error: e, stackTrace: st);
      // Basic backoff: increase attempts and keep it for next run
      // Not implemented detailed attempt count here due to simple MVP
    }
  }
}
