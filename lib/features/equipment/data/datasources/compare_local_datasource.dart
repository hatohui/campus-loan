import 'package:hive/hive.dart';

import '../../../../core/storage/hive_service.dart';

/// Persists the comparison-list device ids across app restarts (CR#2).
///
/// A deliberately tiny data source: the comparison list is just a set of ids,
/// so it maps directly onto one Hive key. Keeping read/write here means the
/// provider never touches Hive itself.
class CompareLocalDataSource {
  CompareLocalDataSource([Box<dynamic>? box])
      : _box = box ?? HiveService.box(HiveService.compareBox);

  final Box<dynamic> _box;

  static const String _idsKey = 'ids';

  /// Reads the persisted device ids (empty list when nothing is stored).
  List<String> readIds() {
    final stored = _box.get(_idsKey);
    if (stored is List) return stored.map((e) => e.toString()).toList();
    return const [];
  }

  /// Overwrites the persisted device ids.
  Future<void> writeIds(List<String> ids) => _box.put(_idsKey, ids);
}
