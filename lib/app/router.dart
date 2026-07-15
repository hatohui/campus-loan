import 'package:go_router/go_router.dart';

import '../features/equipment/domain/entities/device.dart';
import '../features/equipment/presentation/pages/catalogue_page.dart';
import '../features/equipment/presentation/pages/device_detail_page.dart';
import '../features/loan_request/domain/entities/loan_result.dart';
import '../features/loan_request/presentation/pages/loan_form_page.dart';
import '../features/loan_request/presentation/pages/request_result_page.dart';

/// Centralised route paths so widgets never hard-code URL strings.
class AppRoutes {
  const AppRoutes._();

  static const String catalogue = '/';
  static const String result = '/result';

  static String device(String id) => '/device/$id';
  static String loan(String id) => '/loan/$id';
}

/// The app's [GoRouter]. Screens A->B->C->D map onto these four routes.
///
/// Detail and loan routes accept the already-loaded [Device] as `extra` to
/// avoid refetching; the loan and result routes fall back to the catalogue if
/// opened without the object they need (e.g. a cold deep link).
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.catalogue,
  routes: [
    GoRoute(
      path: AppRoutes.catalogue,
      builder: (context, state) => const CataloguePage(),
    ),
    GoRoute(
      path: '/device/:id',
      builder: (context, state) => DeviceDetailPage(
        deviceId: state.pathParameters['id']!,
        initialDevice: state.extra as Device?,
      ),
    ),
    GoRoute(
      path: '/loan/:id',
      builder: (context, state) {
        final device = state.extra as Device?;
        if (device == null) return const CataloguePage();
        return LoanFormPage(device: device);
      },
    ),
    GoRoute(
      path: AppRoutes.result,
      builder: (context, state) {
        final result = state.extra as LoanResult?;
        if (result == null) return const CataloguePage();
        return RequestResultPage(result: result);
      },
    ),
  ],
);
