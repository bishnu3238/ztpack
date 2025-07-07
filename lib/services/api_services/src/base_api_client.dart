import 'package:dartz/dartz.dart';

 import '../../failure/src/network_failure.dart';
import 'api_response/api_responce.dart';
 import 'request_config.dart';

/// Abstract API client
abstract class BaseApiClient {
  Future<Either<NetworkFailure, ApiResponse<T>>> request<T>({
    required RequestConfig config,
    T Function(dynamic data)? responseConverter,
  });

  /// Cancel requests by requestId or all if null.
  void cancelRequests([String? requestId]);

  /// Dispose and cleanup resources.
  Future<void> dispose();
}