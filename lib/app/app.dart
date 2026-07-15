import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'router.dart';

/// Root widget: configures theming, routing and the connectivity-driven retry.
///
/// It listens to connectivity transitions and, when the network returns, flushes
/// the offline pending-request queue exactly once per reconnect. Keeping this
/// side effect at the app root means no individual screen has to own it.
class CampusLoanApp extends ConsumerWidget {
  const CampusLoanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(connectivityStreamProvider, (previous, next) {
      final isOnline = next.valueOrNull ?? false;
      if (isOnline) {
        ref.read(retryPendingRequestsProvider).call();
      }
    });

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF12A594), // teal accent from the design
    );

    return MaterialApp.router(
      title: 'Campus Equipment Loan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F9),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2430),
          ),
          foregroundColor: Color(0xFF1E2430),
        ),
        // Full-width, tall, rounded primary buttons like the mockups.
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: EdgeInsets.zero,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
