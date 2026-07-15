import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/catalogue.dart';

/// Owns the async lifecycle of the device catalogue (loading/data/error).
///
/// Built on [AsyncNotifier] so the UI gets Riverpod's `AsyncValue` states for
/// free. [refresh] keeps the previously loaded devices visible while a refetch
/// is in flight, so pull-to-refresh never flashes an empty screen.
class CatalogueNotifier extends AsyncNotifier<Catalogue> {
  @override
  Future<Catalogue> build() => ref.watch(getDevicesProvider).call();

  /// Explicit refresh (pull-to-refresh / retry button).
  Future<void> refresh() async {
    state = const AsyncValue<Catalogue>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(getDevicesProvider).call(),
    );
  }
}

final catalogueProvider =
    AsyncNotifierProvider<CatalogueNotifier, Catalogue>(CatalogueNotifier.new);
