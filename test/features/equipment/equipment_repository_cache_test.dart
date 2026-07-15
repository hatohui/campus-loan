import 'package:flutter_application_1/core/error/exceptions.dart';
import 'package:flutter_application_1/core/error/failures.dart';
import 'package:flutter_application_1/core/network/network_info.dart';
import 'package:flutter_application_1/features/equipment/data/datasources/equipment_local_datasource.dart';
import 'package:flutter_application_1/features/equipment/data/datasources/equipment_remote_datasource.dart';
import 'package:flutter_application_1/features/equipment/data/repositories/equipment_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// Part 4 — repository test for the device-cache fallback behaviour.
///
/// Uses hand-written fakes (no live network, no Hive) so the online/offline
/// decision is exercised in isolation.
class _FakeRemote implements EquipmentRemoteDataSource {
  _FakeRemote({this.devices, this.error});

  final List<dynamic>? devices;
  final Exception? error;
  int fetchCount = 0;

  @override
  Future<List<dynamic>> fetchDevices() async {
    fetchCount++;
    if (error != null) throw error!;
    return devices!;
  }

  @override
  Future<Map<String, dynamic>> fetchDeviceById(String id) async {
    if (error != null) throw error!;
    return (devices!.first as Map).cast<String, dynamic>();
  }
}

class _FakeLocal implements EquipmentLocalDataSource {
  List<dynamic>? cache;

  @override
  Future<void> cacheDevices(List<dynamic> rawJson) async {
    cache = rawJson;
  }

  @override
  Future<List<dynamic>> getCachedDevices() async {
    final data = cache;
    if (data == null || data.isEmpty) throw const CacheException();
    return data;
  }

  @override
  Future<void> seedIfEmpty() async {}
}

class _FakeNetwork implements NetworkInfo {
  _FakeNetwork(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

void main() {
  final sampleJson = [
    {'id': '1', 'name': 'Google Pixel 6 Pro', 'data': null},
    {'id': '2', 'name': 'Apple iPhone 12', 'data': {'price': 799}},
  ];

  group('EquipmentRepositoryImpl.getDevices', () {
    test('online success returns fresh data and refreshes the cache', () async {
      final remote = _FakeRemote(devices: sampleJson);
      final local = _FakeLocal();
      final repo = EquipmentRepositoryImpl(
        remote: remote,
        local: local,
        networkInfo: _FakeNetwork(true),
      );

      final catalogue = await repo.getDevices();

      expect(catalogue.isFromCache, isFalse);
      expect(catalogue.devices, hasLength(2));
      expect(remote.fetchCount, 1);
      expect(local.cache, sampleJson); // cache was written
    });

    test('remote failure with a cache returns cached devices as offline',
        () async {
      final remote = _FakeRemote(error: const NetworkException());
      final local = _FakeLocal()..cache = sampleJson;
      final repo = EquipmentRepositoryImpl(
        remote: remote,
        local: local,
        networkInfo: _FakeNetwork(true),
      );

      final catalogue = await repo.getDevices();

      expect(catalogue.isFromCache, isTrue);
      expect(catalogue.devices.first.name, 'Google Pixel 6 Pro');
    });

    test('offline with an empty cache surfaces a NetworkFailure', () async {
      final repo = EquipmentRepositoryImpl(
        remote: _FakeRemote(error: const NetworkException()),
        local: _FakeLocal(),
        networkInfo: _FakeNetwork(false),
      );

      expect(repo.getDevices(), throwsA(isA<NetworkFailure>()));
    });
  });
}
