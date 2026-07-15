import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';

/// Search field for the catalogue. Owns its [TextEditingController] locally and
/// forwards keystrokes to [SearchQueryNotifier], which applies the 400 ms
/// debounce (CR#1). The widget itself contains no timing logic.
class CatalogueSearchBar extends ConsumerStatefulWidget {
  const CatalogueSearchBar({super.key});

  @override
  ConsumerState<CatalogueSearchBar> createState() =>
      _CatalogueSearchBarState();
}

class _CatalogueSearchBarState extends ConsumerState<CatalogueSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).setQuery(value);
          setState(() {}); // toggle the clear icon as text changes
        },
        decoration: InputDecoration(
          hintText: 'Search devices by name',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                    setState(() {}); // refresh the suffix icon
                  },
                ),
        ),
      ),
    );
  }
}
