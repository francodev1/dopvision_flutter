import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache_service.dart';
import 'sync_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  final s = CacheService();
  ref.onDispose(() {
    // nothing for now
  });
  return s;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final cache = ref.read(cacheServiceProvider);
  final s = SyncService(cacheService: cache);
  s.init();
  ref.onDispose(() {
    s.dispose();
  });
  return s;
});

