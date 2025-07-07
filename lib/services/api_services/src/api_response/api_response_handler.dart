import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import '../../../failure/failure.dart';
import '../../../failure/src/network_failure.dart';
import '../../api_services.dart';
import 'base_api_response.dart';

/// Extension to help with ApiCallService integration
extension ApiCallServiceResponseHandler on ApiCallService {
  /// Generic method to handle API requests that return BaseApiResponse types
  Future<Either<NetworkFailure, T>> requestWithResponseType<T extends BaseApiResponse>({
    required RequestConfig config,
    required T Function(Map<String, dynamic>) responseConverter,
  }) async {
    try {
      final response = await request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) {
          if (data is! Map<String, dynamic>) {
            dev.log('Unexpected response format: $data');
            throw FormatException('Unexpected response format');
          }
          return data;
        },
      );

      return response.fold(
            (failure) => left(failure),
            (apiResponse) {
          try {
            final typedResponse = responseConverter(apiResponse.data!);
            return right(typedResponse);
          } catch (e, stackTrace) {
            dev.log('Error converting response: $e', error: e, stackTrace: stackTrace);
            return left(
              NetworkFailure(
                message: 'Failed to parse response: ${e.toString()}',
                type: NetworkErrorType.parseError,
                stackTrace: stackTrace,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      dev.log('Error in requestWithResponseType: $e', error: e, stackTrace: stackTrace);
      return left(
        NetworkFailure(
          message: 'Request error: ${e.toString()}',
          type: NetworkErrorType.unknown,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Helper for handling MultiStateApiResponse types
  Future<Either<NetworkFailure, MultiStateApiResponse<T, E>>> requestMultiState<T, E extends Object>({
    required RequestConfig config,
    required MultiStateApiResponse<T, E> Function(Map<String, dynamic>) responseConverter,
  }) async {
    return requestWithResponseType<MultiStateApiResponse<T, E>>(
      config: config,
      responseConverter: responseConverter,
    );
  }

  /// Helper for handling DataListApiResponse types
  Future<Either<NetworkFailure, DataListApiResponse<T>>> requestList<T>({
    required RequestConfig config,
    required T Function(Map<String, dynamic>) itemConverter,
  }) async {
    return requestWithResponseType<DataListApiResponse<T>>(
      config: config,
      responseConverter: (json) => DataListApiResponse<T>.fromJson(json, itemConverter),
    );
  }

  /// Helper for handling DataItemApiResponse types
  Future<Either<NetworkFailure, DataItemApiResponse<T>>> requestItem<T>({
    required RequestConfig config,
    required T Function(Map<String, dynamic>) itemConverter,
  }) async {
    return requestWithResponseType<DataItemApiResponse<T>>(
      config: config,
      responseConverter: (json) => DataItemApiResponse<T>.fromJson(json, itemConverter),
    );
  }
}

