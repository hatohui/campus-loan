import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/compare_local_datasource.dart';

/// Owns the comparison list of device ids, capped and persisted (CR#2).
///
/// The two-device limit is enforced in exactly one place — [toggle] — which
/// answers "where is the two-device limit enforced?". The list is loaded from
/// and written back to Hive via [CompareLocalDataSource], so the selection
/// survives an app restart.
class CompareNotifier extends Notifier<List<String>> {
  late final CompareLocalDataSource _store;

  @override
  List<String> build() {
    _store = ref.watch(compareLocalDataSourceProvider);
    return _store.readIds();
  }

  bool isSelected(String id) => state.contains(id);

  /// True when the list already holds [AppConstants.maxCompareItems] devices.
  bool get isFull => state.length >= AppConstants.maxCompareItems;

  /// Adds or removes [id]. Adding is a no-op once the cap is reached, which is
  /// the single enforcement point for the "at most two devices" rule.
  Future<void> toggle(String id) async {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
    } else if (state.length < AppConstants.maxCompareItems) {
      state = [...state, id];
    } else {
      return; // Cap reached: ignore the extra selection.
    }
    await _store.writeIds(state);
  }

  Future<void> clear() async {
    state = const [];
    await _store.writeIds(state);
  }
}

final compareProvider =
    NotifierProvider<CompareNotifier, List<String>>(CompareNotifier.new);
