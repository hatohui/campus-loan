import '../../../../core/utils/deposit_calculator.dart';

/// Coarse category inferred from a device's name/attributes.
///
/// The public API returns free-form objects with no category field, so we
/// derive one for display and grouping. [other] is the safe fallback.
enum DeviceCategory {
  phone('Phone'),
  laptop('Laptop'),
  tablet('Tablet'),
  watch('Watch'),
  audio('Audio'),
  television('TV'),
  monitor('Monitor'),
  console('Console'),
  accessory('Accessory'),
  other('Device');

  const DeviceCategory(this.label);

  /// Human-readable label shown in the UI.
  final String label;
}

/// Immutable domain entity representing a borrowable device.
///
/// This is the shape the presentation layer consumes. It is intentionally
/// free of any JSON/transport concerns — mapping lives in the data layer's
/// `DeviceModel`. Optional fields ([year], [price]) are nullable because the
/// upstream API frequently omits them, and the detail screen must degrade
/// gracefully when they are missing.
class Device {
  const Device({
    required this.id,
    required this.name,
    required this.category,
    required this.attributes,
    required this.apiIndex,
    this.year,
    this.price,
  });

  /// Server-assigned identifier (kept as a string, as the API returns).
  final String id;

  /// Display name of the device.
  final String name;

  /// Category inferred from [name]/[attributes] for display.
  final DeviceCategory category;

  /// Release year if it could be inferred, otherwise `null`.
  final int? year;

  /// Price if the API supplied one, otherwise `null`.
  final num? price;

  /// Raw, non-null attribute map from the API's `data` field (may be empty).
  /// Retained so the detail screen can list whatever optional fields exist.
  final Map<String, dynamic> attributes;

  /// Original position in the API response, used to restore the source order
  /// during sorting (CR#4).
  final int apiIndex;

  /// Estimated deposit derived from [price] via the shared deposit rule.
  double get estimatedDeposit => DepositCalculator.estimate(price);

  @override
  bool operator ==(Object other) =>
      other is Device && other.id == id && other.apiIndex == apiIndex;

  @override
  int get hashCode => Object.hash(id, apiIndex);
}
