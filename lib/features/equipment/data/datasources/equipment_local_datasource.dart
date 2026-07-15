import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import 'device_seed_data.dart';

/// Local cache for the device catalogue, backed by a Hive box.
abstract interface class EquipmentLocalDataSource {
  /// Overwrites the cached catalogue with the latest raw JSON list.
  Future<void> cacheDevices(List<dynamic> rawJson);

  /// Returns the cached raw JSON list, or throws [CacheException] if empty.
  Future<List<dynamic>> getCachedDevices();

  /// Populates the cache with bundled seed data if it is currently empty.
  Future<void> seedIfEmpty();
}

/// Hive-backed [EquipmentLocalDataSource].
///
/// Stores the raw API list verbatim under a single key. Persisting the raw
/// payload (rather than mapped entities) keeps the cache format identical to
/// the network format, so exactly one mapper path is exercised on read.
class EquipmentLocalDataSourceImpl implements EquipmentLocalDataSource {
  EquipmentLocalDataSourceImpl([Box<dynamic>? box])
      : _box = box ?? HiveService.box(HiveService.catalogueBox);

  final Box<dynamic> _box;

  static const String _devicesKey = 'devices';
  static const String _cachedAtKey = 'cached_at';

  @override
  Future<void> cacheDevices(List<dynamic> rawJson) async {
    await _box.put(_devicesKey, rawJson);
    await _box.put(_cachedAtKey, DateTime.now().toIso8601String());
  }

  @override
  Future<List<dynamic>> getCachedDevices() async {
    final cached = _box.get(_devicesKey);
    if (cached is List && cached.isNotEmpty) return cached;
    throw const CacheException();
  }

  @override
  Future<void> seedIfEmpty() async {
    final existing = _box.get(_devicesKey);
    final hasData = existing is List && existing.isNotEmpty;
    if (!hasData) {
      await cacheDevices(kDeviceSeedData);
    }
  }
}
