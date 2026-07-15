import 'package:hive/hive.dart';

import '../../../../core/storage/hive_service.dart';

/// Local persistence for the loan draft and the offline pending queue.
///
/// Two concerns share this data source because both are simple key/value
/// writes against Hive: the single current [draft] and the list of pending
/// request [records]. Each pending record is a plain map so no TypeAdapter is
/// required.
class LoanLocalDataSource {
  LoanLocalDataSource({Box<dynamic>? draftBox, Box<dynamic>? pendingBox})
      : _draftBox = draftBox ?? HiveService.box(HiveService.draftBox),
        _pendingBox = pendingBox ?? HiveService.box(HiveService.pendingBox);

  final Box<dynamic> _draftBox;
  final Box<dynamic> _pendingBox;

  static const String _draftKey = 'current';
  static const String _pendingKey = 'records';

  // --- draft -------------------------------------------------------------

  Future<void> saveDraft(Map<String, dynamic> json) =>
      _draftBox.put(_draftKey, json);

  Map<String, dynamic>? loadDraft() {
    final raw = _draftBox.get(_draftKey);
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  Future<void> clearDraft() => _draftBox.delete(_draftKey);

  // --- pending queue -----------------------------------------------------

  /// Returns the stored pending records as a mutable list of maps.
  List<Map<String, dynamic>> readPending() {
    final raw = _pendingBox.get(_pendingKey);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  /// Persists the full pending list (used after adds and retries).
  Future<void> writePending(List<Map<String, dynamic>> records) =>
      _pendingBox.put(_pendingKey, records);
}
