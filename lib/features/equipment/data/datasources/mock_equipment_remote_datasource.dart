import 'device_seed_data.dart';
import 'equipment_remote_datasource.dart';

/// In-memory [EquipmentRemoteDataSource] used in mock mode (demo / rate-limit
/// fallback). Serves the bundled seed catalogue with a small simulated latency
/// so the loading state is still visible.
class MockEquipmentRemoteDataSource implements EquipmentRemoteDataSource {
  const MockEquipmentRemoteDataSource();

  @override
  Future<List<dynamic>> fetchDevices() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return kDeviceSeedData;
  }

  @override
  Future<Map<String, dynamic>> fetchDeviceById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return kDeviceSeedData.firstWhere(
      (d) => d['id'] == id,
      orElse: () => kDeviceSeedData.first,
    );
  }
}
