import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../features/equipment/data/datasources/compare_local_datasource.dart';
import '../features/equipment/data/datasources/equipment_local_datasource.dart';
import '../features/equipment/data/datasources/equipment_remote_datasource.dart';
import '../features/equipment/data/datasources/mock_equipment_remote_datasource.dart';
import '../features/equipment/data/repositories/equipment_repository_impl.dart';
import '../features/equipment/domain/repositories/equipment_repository.dart';
import '../features/equipment/domain/usecases/get_device_by_id.dart';
import '../features/equipment/domain/usecases/get_devices.dart';
import '../features/loan_request/data/datasources/loan_local_datasource.dart';
import '../features/loan_request/data/datasources/loan_remote_datasource.dart';
import '../features/loan_request/data/datasources/mock_loan_remote_datasource.dart';
import '../features/loan_request/data/repositories/loan_repository_impl.dart';
import '../features/loan_request/domain/repositories/loan_repository.dart';
import '../features/loan_request/domain/usecases/retry_pending_requests.dart';
import '../features/loan_request/domain/usecases/submit_loan_request.dart';
import '../features/loan_request/domain/usecases/validate_loan_period.dart';

/// Composition root: wires infrastructure -> data sources -> repositories ->
/// use cases as Riverpod providers.
///
/// This is the *only* place concrete implementations are constructed, so the
/// dependency graph is visible in one file and every layer above depends on
/// abstractions. Tests override the leaf providers (e.g. the repository) to
/// swap in fakes without touching the widgets.

// --- infrastructure ------------------------------------------------------

final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.create();
  ref.onDispose(dio.close);
  return dio;
});

final connectivityProvider =
    Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

/// Emits `true`/`false` as connectivity changes; drives pending-request retry.
final connectivityStreamProvider = StreamProvider<bool>(
  (ref) => ref.watch(networkInfoProvider).onConnectivityChanged,
);

// --- equipment feature ---------------------------------------------------

final _equipmentRemoteProvider = Provider<EquipmentRemoteDataSource>(
  (ref) => EquipmentRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final _equipmentLocalProvider = Provider<EquipmentLocalDataSource>(
  (ref) => EquipmentLocalDataSourceImpl(),
);

final compareLocalDataSourceProvider =
    Provider<CompareLocalDataSource>((ref) => CompareLocalDataSource());

final equipmentRepositoryProvider = Provider<EquipmentRepository>(
  (ref) => EquipmentRepositoryImpl(
    remote: ref.watch(_equipmentRemoteProvider),
    local: ref.watch(_equipmentLocalProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final getDevicesProvider = Provider<GetDevices>(
  (ref) => GetDevices(ref.watch(equipmentRepositoryProvider)),
);

final getDeviceByIdProvider = Provider<GetDeviceById>(
  (ref) => GetDeviceById(ref.watch(equipmentRepositoryProvider)),
);

// --- loan_request feature ------------------------------------------------

final _loanRemoteProvider = Provider<LoanRemoteDataSource>(
  (ref) => LoanRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final _loanLocalProvider =
    Provider<LoanLocalDataSource>((ref) => LoanLocalDataSource());

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepositoryImpl(
    remote: ref.watch(_loanRemoteProvider),
    local: ref.watch(_loanLocalProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final submitLoanRequestProvider = Provider<SubmitLoanRequest>(
  (ref) => SubmitLoanRequest(ref.watch(loanRepositoryProvider)),
);

final retryPendingRequestsProvider = Provider<RetryPendingRequests>(
  (ref) => RetryPendingRequests(ref.watch(loanRepositoryProvider)),
);

final validateLoanPeriodProvider =
    Provider<ValidateLoanPeriod>((ref) => const ValidateLoanPeriod());
