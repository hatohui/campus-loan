import '../entities/device.dart';
import '../repositories/equipment_repository.dart';

/// Use case: load a single device's detail by id.
class GetDeviceById {
  const GetDeviceById(this._repository);

  final EquipmentRepository _repository;

  Future<Device> call(String id) => _repository.getDeviceById(id);
}
