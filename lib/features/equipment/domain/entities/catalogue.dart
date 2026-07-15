import 'device.dart';

/// Result of loading the device catalogue.
///
/// Wrapping the list lets the repository tell the UI *where* the data came
/// from: when [isFromCache] is true the network failed and we fell back to the
/// last cached snapshot, which is exactly when the offline banner must show.
class Catalogue {
  const Catalogue({required this.devices, required this.isFromCache});

  final List<Device> devices;

  /// True when these devices were served from the local cache after a remote
  /// failure (drives the offline banner).
  final bool isFromCache;

  bool get isEmpty => devices.isEmpty;
}
