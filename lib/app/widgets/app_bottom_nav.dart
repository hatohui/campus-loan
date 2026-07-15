import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/equipment/presentation/widgets/watchlist_sheet.dart';
import '../router.dart';

/// The app's persistent bottom navigation bar (matches the reference design).
///
/// The graded scope is a single tab — "Explore" (the catalogue) — so Home and
/// Explore both go to the catalogue and Saved opens the watchlist. Profile is a
/// visual placeholder from the design and is intentionally inert. Kept as one
/// reusable widget so every screen shows an identical bar.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      child: NavigationBar(
        selectedIndex: 1, // Explore is the implemented tab
        height: 64,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
      case 1:
        context.go(AppRoutes.catalogue);
      case 2:
        showWatchlistSheet(context);
      case 3:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Profile is out of scope.')),
          );
    }
  }
}
