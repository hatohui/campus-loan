import '../entities/catalogue.dart';
import '../entities/device.dart';

/// Domain contract for reading the equipment catalogue.
///
/// The presentation layer depends only on this interface; the concrete
/// implementation in the data layer decides between remote and cached sources.
/// Methods throw a [Failure] (see `core/error/failures.dart`) on error, which
/// Riverpod's `AsyncValue` captures into the UI error state.
abstract interface class EquipmentRepository {
  /// Loads all devices, transparently falling back to cache when offline.
  Future<Catalogue> getDevices();

  /// Loads a single device by [id]; prefers cache when the network is down.
  Future<Device> getDeviceById(String id);
}
