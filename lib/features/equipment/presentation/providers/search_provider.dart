import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';

/// Owns the catalogue search query **and** its debounce lifecycle (CR#1).
///
/// This is the single provider that answers "which provider owns the query and
/// cancellation/debounce lifecycle?": the exposed [state] is the *debounced*
/// query. Every keystroke calls [setQuery], which cancels the previous timer
/// and schedules a new one, so downstream filtering only re-runs once the user
/// pauses for [AppConstants.searchDebounce]. Filtering is done locally over the
/// already-loaded list, so the remote API is never re-hit while typing.
class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  /// Schedules a debounced update of the query from raw text-field input.
  void setQuery(String raw) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () => state = raw.trim());
  }

  /// Clears the query immediately (no debounce) when the field is cleared.
  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
