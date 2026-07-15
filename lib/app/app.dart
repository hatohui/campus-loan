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

    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    return MaterialApp.router(
      title: 'Campus Equipment Loan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
