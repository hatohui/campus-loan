import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over the platform connectivity check.
///
/// Repositories depend on this interface rather than on `connectivity_plus`
/// directly, so tests can supply a fake that reports online/offline on demand
/// without touching real hardware.
abstract interface class NetworkInfo {
  /// Whether the device currently has a usable network interface.
  Future<bool> get isConnected;

  /// Emits whenever connectivity transitions (used to trigger pending retry).
  Stream<bool> get onConnectivityChanged;
}

/// Default [NetworkInfo] backed by the `connectivity_plus` plugin.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> get isConnected async =>
      _hasConnection(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);
}
