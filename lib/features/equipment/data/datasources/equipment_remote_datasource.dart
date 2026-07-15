import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote source for the device catalogue (talks to the public REST API).
abstract interface class EquipmentRemoteDataSource {
  /// `GET /objects` — returns the raw JSON list untouched for the mapper.
  Future<List<dynamic>> fetchDevices();

  /// `GET /objects/{id}` — returns one raw JSON object.
  Future<Map<String, dynamic>> fetchDeviceById(String id);
}

/// Dio-backed [EquipmentRemoteDataSource].
///
/// Translates Dio's transport-level errors into the data layer's own
/// [NetworkException]/[ServerException] so the repository stays decoupled from
/// the HTTP client.
class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  const EquipmentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<dynamic>> fetchDevices() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.objects);
      final data = response.data;
      if (data is List) return data;
      throw const ServerException('Unexpected catalogue response shape.');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDeviceById(String id) async {
    try {
      final response =
          await _dio.get<dynamic>(ApiConstants.objectById(id));
      final data = response.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw const ServerException('Unexpected device response shape.');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Distinguishes "no connection" from "server said no" so the repository can
  /// choose between an offline fallback and a hard error.
  Exception _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        return ServerException(
          e.message ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
