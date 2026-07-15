import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import 'catalogue_provider.dart';

/// Holds the selected category chip. `null` means "All".
class CategoryFilterNotifier extends Notifier<DeviceCategory?> {
  @override
  DeviceCategory? build() => null;

  void select(DeviceCategory? category) => state = category;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, DeviceCategory?>(
  CategoryFilterNotifier.new,
);

/// The distinct categories actually present in the loaded catalogue, in enum
/// order — used to build the filter chip row so chips reflect real data.
final availableCategoriesProvider = Provider<List<DeviceCategory>>((ref) {
  final devices =
      ref.watch(catalogueProvider).valueOrNull?.devices ?? const <Device>[];
  final present = devices.map((d) => d.category).toSet();
  return DeviceCategory.values.where(present.contains).toList();
});
