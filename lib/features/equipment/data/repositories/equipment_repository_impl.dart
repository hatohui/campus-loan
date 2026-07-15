import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/catalogue.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../datasources/equipment_local_datasource.dart';
import '../datasources/equipment_remote_datasource.dart';
import '../models/device_model.dart';

/// Concrete [EquipmentRepository] implementing the online/offline strategy.
///
/// Policy: when connected, fetch remotely and refresh the cache; on any remote
/// failure (or when offline to begin with), fall back to the cached snapshot
/// and flag it as [Catalogue.isFromCache] so the UI shows the offline banner.
/// Only when there is neither network nor cache does it surface a [Failure].
class EquipmentRepositoryImpl implements EquipmentRepository {
  const EquipmentRepositoryImpl({
    required this._remote,
    required this._local,
    required this._networkInfo,
  });

  final EquipmentRemoteDataSource _remote;
  final EquipmentLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Catalogue> getDevices() async {
    if (await _networkInfo.isConnected) {
      try {
        final raw = await _remote.fetchDevices();
        await _local.cacheDevices(raw);
        return Catalogue(
          devices: DeviceModel.fromJsonList(raw),
          isFromCache: false,
        );
      } on NetworkException {
        return _cachedCatalogue();
      } on ServerException catch (e) {
        // Prefer stale data over a hard error, matching the offline spec.
        return _cachedCatalogue(
          onMiss: ServerFailure(e.message, e.statusCode ?? 502),
        );
      }
    }
    return _cachedCatalogue();
  }

  @override
  Future<Device> getDeviceById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final raw = await _remote.fetchDeviceById(id);
        return DeviceModel.fromJson(raw);
      } on NetworkException {
        return _cachedDevice(id);
      } on ServerException catch (e) {
        return _cachedDevice(
          id,
          onMiss: ServerFailure(e.message, e.statusCode ?? 502),
        );
      }
    }
    return _cachedDevice(id);
  }

  /// Returns the cached catalogue, or throws [onMiss] (default: offline).
  Future<Catalogue> _cachedCatalogue({Failure? onMiss}) async {
    try {
      final cached = await _local.getCachedDevices();
      return Catalogue(
        devices: DeviceModel.fromJsonList(cached),
        isFromCache: true,
      );
    } on CacheException {
      throw onMiss ?? const NetworkFailure();
    }
  }

  /// Resolves a single device from the cached list, or throws [onMiss].
  Future<Device> _cachedDevice(String id, {Failure? onMiss}) async {
    try {
      final cached = await _local.getCachedDevices();
      for (final device in DeviceModel.fromJsonList(cached)) {
        if (device.id == id) return device;
      }
      throw onMiss ?? const CacheFailure('Device not found in cache.');
    } on CacheException {
      throw onMiss ?? const NetworkFailure();
    }
  }
}
