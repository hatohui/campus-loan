import 'package:hive_flutter/hive_flutter.dart';

/// Owns Hive initialisation and hands out the app's raw boxes.
///
/// We deliberately use untyped [Box] instances that store plain JSON-compatible
/// maps and lists. This avoids generated TypeAdapters (and `build_runner`),
/// keeping the persistence layer small and fully explainable while still giving
/// every layer a single, injectable entry point for local storage.
class HiveService {
  HiveService._();

  /// Cached device catalogue (list of raw JSON maps) + a fetch timestamp.
  static const String catalogueBox = 'catalogue_cache';

  /// Persisted comparison-list device ids (CR#2).
  static const String compareBox = 'compare_selection';

  /// Persisted loan-request draft (survives app restart).
  static const String draftBox = 'loan_draft';

  /// Queue of pending (offline) loan requests awaiting retry.
  static const String pendingBox = 'pending_requests';

  static bool _initialised = false;

  /// Initialises Hive and opens every box. Safe to call more than once.
  static Future<void> init() async {
    if (_initialised) return;
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(catalogueBox),
      Hive.openBox<dynamic>(compareBox),
      Hive.openBox<dynamic>(draftBox),
      Hive.openBox<dynamic>(pendingBox),
    ]);
    _initialised = true;
  }

  static Box<dynamic> box(String name) => Hive.box<dynamic>(name);
}
