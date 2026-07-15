import '../entities/catalogue.dart';
import '../repositories/equipment_repository.dart';

/// Use case: load the full device catalogue.
///
/// A single-responsibility wrapper around the repository. It exists so the
/// presentation layer expresses intent ("get devices") without knowing about
/// the repository interface, keeping the dependency direction pointing inward.
class GetDevices {
  const GetDevices(this._repository);

  final EquipmentRepository _repository;

  Future<Catalogue> call() => _repository.getDevices();
}
