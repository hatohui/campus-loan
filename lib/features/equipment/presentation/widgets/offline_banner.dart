import 'package:flutter/material.dart';

/// Thin banner shown above the catalogue when data is served from cache.
///
/// Presentation-only: it is told whether to show via a bool, so it has no
/// knowledge of *why* the app is offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message = 'Offline — showing cached devices'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 18, color: scheme.onTertiaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
