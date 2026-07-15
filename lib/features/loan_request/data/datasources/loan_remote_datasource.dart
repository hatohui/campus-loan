import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Remote source responsible for creating loan requests via `POST /objects`.
abstract interface class LoanRemoteDataSource {
  /// Posts [payload] and returns the created object (containing id/createdAt).
  Future<Map<String, dynamic>> submitLoan(Map<String, dynamic> payload);
}

/// Dio-backed [LoanRemoteDataSource].
class LoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  const LoanRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> submitLoan(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.objects,
        data: payload,
      );
      final data = response.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw const ServerException('Unexpected create response shape.');
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.connectionError:
          throw const NetworkException();
        default:
          throw ServerException(
            e.message ?? 'Server rejected the request',
            statusCode: e.response?.statusCode,
          );
      }
    }
  }
}
