import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/device.dart';

/// Fetches a single device by id (used when the detail screen is opened without
/// an already-loaded [Device], e.g. via a deep link or after a cold start).
final deviceDetailProvider = FutureProvider.family<Device, String>(
  (ref, id) => ref.watch(getDeviceByIdProvider).call(id),
);
