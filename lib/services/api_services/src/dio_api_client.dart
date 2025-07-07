import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import '../../connectivity_service/connectivity_service.dart';
import '../../failure/src/network_failure.dart';
import 'api_response/api_responce.dart';
import 'auth_service.dart';
import 'base_api_client.dart';
import 'catch_service.dart';
import 'log_service.dart';
import 'request_config.dart';
/// Dio implementation
class DioApiClient implements BaseApiClient {
  final dio.Dio _dio;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  final AuthService _authService;
  final LogService _logger;
  final Map<String, dio.CancelToken> _cancelTokens = {};

  DioApiClient({
    required LogService logger,
    required CacheService cacheService,
    required ConnectivityService connectivityService,
    required AuthService authService,
    String? baseUrl,
    Map<String, dynamic>? defaultHeaders,
    Duration? defaultTimeout,
  }) : _logger = logger,
       _cacheService = cacheService,
       _connectivityService = connectivityService,
       _authService = authService,
       _dio = dio.Dio(
         dio.BaseOptions(
           baseUrl: baseUrl ?? '',
           connectTimeout: defaultTimeout ?? const Duration(seconds: 30),
           receiveTimeout: defaultTimeout ?? const Duration(seconds: 30),
           headers: defaultHeaders ?? {'Content-Type': 'application/json'},

         ),
       ) {
    // Add interceptors
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.debug(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.error(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            error.message,
            error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );
  }

  @override
  Future<Either<NetworkFailure, ApiResponse<T>>> request<T>({
    required RequestConfig config,
    T Function(dynamic data)? responseConverter,
  }) async {
    final requestId = config.requestId ?? _generateRequestId(config);
    final cancelToken = dio.CancelToken();
    _cancelTokens[requestId] = cancelToken;

    // Handle caching
    if (config.cachePolicy != CachePolicy.networkOnly &&
        config.cachePolicy != CachePolicy.noCache) {
      final cacheKey = config.cacheKey ?? _generateCacheKey(config);
      final cachedData = await _cacheService.getCache(cacheKey);

      if (cachedData != null) {
        if (config.cachePolicy == CachePolicy.cacheOnly ||
            config.cachePolicy == CachePolicy.cacheFirst) {
          _logger.info('Using cached data for request: ${config.fullUrl}');
          final convertedData =
              responseConverter != null
                  ? responseConverter(cachedData)
                  : cachedData as T;

          final response = ApiResponse<T>(
            data: convertedData,
            statusCode: 200,
            isFromCache: true,
          );

          // If cache-first, fetch fresh data in background
          if (config.cachePolicy == CachePolicy.cacheFirst) {
            // _fetchAndCacheData(config, cacheKey, responseConverter);
            unawaited(_fetchAndCacheData(config, cacheKey, responseConverter));
          }

          _cancelTokens.remove(requestId);
          return right(response);
        }
      } else if (config.cachePolicy == CachePolicy.cacheOnly) {
        _cancelTokens.remove(requestId);
        return left(
          NetworkFailure(
            message: 'No cached data available',
            type: NetworkErrorType.notFound,
          ),
        );
      }
    }

    // Check connectivity if needed
    if (config.cachePolicy != CachePolicy.cacheOnly) {
      final isConnected = await _connectivityService.hasActiveInternet();
      if (!isConnected) {
        _cancelTokens.remove(requestId);
        return left(
          NetworkFailure(
            message: 'No internet connection',
            type: NetworkErrorType.noInternet,
          ),
        );
      }
    }

    // Add auth headers if required
    Map<String, dynamic> headers = Map.from(config.headersMap);
    if (config.requiresAuth) {
      final authHeaders = await _authService.getAuthHeaders();
      headers.addAll(authHeaders);
    }

    try {
      // Prepare request options
      final options = dio.Options(
        headers: headers,
        sendTimeout: config.timeout,
        receiveTimeout: config.timeout,
        responseType: _getResponseType(config.responseFormat),
      );

      // Prepare request method and execute
      dio.Response response;
      final url = config.fullUrl;

      switch (config.method) {
        case RequestMethod.get:
          response = await _dio.get(
            url,
            queryParameters: config.queryParameters,
            options: options,
            cancelToken: cancelToken,
            onReceiveProgress: config.onReceiveProgress,
          );
          break;
        case RequestMethod.post:
          response = await _dio.post(
            url,
            data: config.body,
            queryParameters: config.queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: config.onSendProgress,
            onReceiveProgress: config.onReceiveProgress,
          );
          break;
        case RequestMethod.put:
          response = await _dio.put(
            url,
            data: config.body,
            queryParameters: config.queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: config.onSendProgress,
            onReceiveProgress: config.onReceiveProgress,
          );
          break;
        case RequestMethod.patch:
          response = await _dio.patch(
            url,
            data: config.body,
            queryParameters: config.queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: config.onSendProgress,
            onReceiveProgress: config.onReceiveProgress,
          );
          break;
        case RequestMethod.delete:
          response = await _dio.delete(
            url,
            data: config.body,
            queryParameters: config.queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;
      }

      // Process response
      final responseData = response.data;
      final statusCode = response.statusCode ?? 200;
      final responseHeaders = response.headers.map;

      // Convert data if converter provided
      final convertedData =
          responseConverter != null
              ? responseConverter(responseData)
              : config.customResponseDecoder != null
                  ? config.customResponseDecoder!(responseData) as T
                  : responseData as T;

      final apiResponse = ApiResponse<T>(
        data: convertedData,
        statusCode: statusCode,
        headers: responseHeaders.map((k, v) => MapEntry(k, v.join(', '))),
      );

      // Cache response if needed
      if (config.cachePolicy != CachePolicy.noCache &&
          config.cachePolicy != CachePolicy.networkOnly &&
          statusCode >= 200 &&
          statusCode < 300) {
        final cacheKey = config.cacheKey ?? _generateCacheKey(config);
        await _cacheService.setCache(
          cacheKey,
          responseData,
          config.cacheDuration,
        );
      }

      _cancelTokens.remove(requestId);
      return right(apiResponse);
    } on dio.DioException catch (e, stack) {
      _cancelTokens.remove(requestId);

      if (e.type == dio.DioExceptionType.cancel) {
        return left(
          NetworkFailure(
            message: 'Request cancelled',
            statusCode: e.response?.statusCode,
            data: e.response?.data,
            stackTrace: stack,
            type: NetworkErrorType.cancelled,
          ),
        );
      }

      // Retry logic
      if (config.retryEnabled &&
          (e.type == dio.DioExceptionType.connectionTimeout ||
              e.type == dio.DioExceptionType.sendTimeout ||
              e.type == dio.DioExceptionType.receiveTimeout)) {
        return await _retryRequest(config, responseConverter);
      }

      return left(_handleDioError(e, stack));
    } catch (e, stack) {
      _cancelTokens.remove(requestId);
      _logger.error('Unexpected error during request', e, stack);

      return left(
        NetworkFailure(
          message: 'Unexpected error: ${e.toString()}',
          stackTrace: stack,
          type: NetworkErrorType.unknown,
        ),
      );
    }
  }

  @override
  void cancelRequests([String? requestId]) {
    if (requestId != null) {
      if (_cancelTokens.containsKey(requestId)) {
        _cancelTokens[requestId]!.cancel('Request cancelled');
        _cancelTokens.remove(requestId);
        _logger.debug('Cancelled request: $requestId');
      }
    } else {
      // Cancel all requests

      for (var token in _cancelTokens.values) {
        token.cancel('All requests cancelled');
      }
      _cancelTokens.clear();
    }
    _logger.debug('Cancelled ${requestId ?? 'all'} requests');
  }

  @override
  Future<void> dispose() async {
    cancelRequests();
    _dio.close(force: true);
    _logger.debug('Disposed DioApiClient');
  }

  // Helper methods
  dio.ResponseType _getResponseType(ResponseFormat format) {
    switch (format) {
      case ResponseFormat.json:
        return dio.ResponseType.json;
      case ResponseFormat.plain:
        return dio.ResponseType.plain;
      case ResponseFormat.bytes:
        return dio.ResponseType.bytes;
      case ResponseFormat.stream:
        return dio.ResponseType.stream;
    }
  }

  String _generateRequestId(RequestConfig config) {
    return '${config.method.name}_${config.fullUrl}_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateCacheKey(RequestConfig config) {
    final queryString =
        config.queryParameters?.isNotEmpty == true
            ? '_${jsonEncode(config.queryParameters)}'
            : '';
    final bodyString = config.body != null ? '_${jsonEncode(config.body)}' : '';
    return '${config.method.name}_${config.fullUrl}$queryString$bodyString';
  }

  Future<void> _fetchAndCacheData<T>(
    RequestConfig config,
    String cacheKey,
    T Function(dynamic data)? responseConverter,
  ) async {
    try {
      // Clone config but change cache policy
      final newConfig = RequestConfig(
        baseUrl: config.baseUrl,
        endpoint: config.endpoint,
        method: config.method,
        queryParameters: config.queryParameters,
        headers: config.headers,
        body: config.body,
        responseFormat: config.responseFormat,
        timeout: config.timeout,
        requiresAuth: config.requiresAuth,
        cachePolicy: CachePolicy.networkOnly,
        cacheDuration: config.cacheDuration,
      );

      // Make background request
      final result = await request(
        config: newConfig,
        responseConverter: responseConverter,
      );

      result.fold(
        (failure) => _logger.warning(
          'Background fetch failed for cache refresh: ${failure.message}',
        ),
        (response) =>
            _logger.debug('Successfully refreshed cache for: $cacheKey'),
      );
    } catch (e, stack) {
      _logger.error('Error in background fetch for cache', e, stack);
    }
  }

  Future<Either<NetworkFailure, ApiResponse<T>>> _retryRequest<T>(
    RequestConfig config,
    T Function(dynamic data)? responseConverter, {
    int retryCount = 0,
  }) async {
    if (retryCount >= config.maxRetries) {
      return left(
        NetworkFailure(
          message: 'Max retries exceeded',
          type: NetworkErrorType.timeout,
        ),
      );
    }

    _logger.warning(
      'Retrying request (${retryCount + 1}/${config.maxRetries}): ${config.fullUrl}',
    );

    // Exponential backoff
    final delay = config.retryDelay ?? Duration(milliseconds: 1000 * (1 << retryCount));
    await Future.delayed(delay);

    try {
      return await request(
        config: config,
        responseConverter: responseConverter,
      );
    } catch (e) {
      return _retryRequest(
        config,
        responseConverter,
        retryCount: retryCount + 1,
      );
    }
  }

  NetworkFailure _handleDioError(dio.DioException e, StackTrace stackTrace) {
    _logger.error(
      'Dio Error: ${e.message}, Response: ${e.response?.data}',
      e,
      stackTrace,
    );

    final statusCode = e.response?.statusCode;
    final responseData =
        e.response?.data is String
            ? {'raw': e.response?.data} // Store raw HTML for debugging
            : e.response?.data;
    // Extract error message if available
    String errorMessage = e.message ?? 'Unknown error';

    if (responseData != null && responseData is Map) {
      if (responseData.containsKey('message')) {
        errorMessage = responseData['message'].toString();
      } else if (responseData.containsKey('error')) {
        errorMessage = responseData['error'].toString();
      }
    }

    NetworkErrorType errorType;

    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        errorType = NetworkErrorType.timeout;
        break;
      case dio.DioExceptionType.badResponse:
        if (statusCode != null) {
          if (statusCode == 400) {
            errorType = NetworkErrorType.badRequest;
          } else if (statusCode == 401) {
            errorType = NetworkErrorType.unauthorized;
          } else if (statusCode == 403) {
            errorType = NetworkErrorType.forbidden;
          } else if (statusCode == 404) {
            errorType = NetworkErrorType.notFound;
          } else if (statusCode >= 500) {
            errorType = NetworkErrorType.serverError;
          } else {
            errorType = NetworkErrorType.unknown;
          }
        } else {
          errorMessage =
              e.type == dio.DioExceptionType.connectionTimeout ||
                      e.type == dio.DioExceptionType.sendTimeout ||
                      e.type == dio.DioExceptionType.receiveTimeout
                  ? 'Request timed out'
                  : 'Unknown error';
          errorType = NetworkErrorType.unknown;
        }
        break;
      case dio.DioExceptionType.cancel:
        errorType = NetworkErrorType.cancelled;
        break;
      default:
        errorMessage =
            e.type == dio.DioExceptionType.connectionTimeout ||
                    e.type == dio.DioExceptionType.sendTimeout ||
                    e.type == dio.DioExceptionType.receiveTimeout
                ? 'Request timed out'
                : 'Unknown error';
        errorType = NetworkErrorType.unknown;
    }

    return NetworkFailure(
      message: errorMessage,
      statusCode: statusCode,
      data: responseData,
      stackTrace: stackTrace,
      type: errorType,
    );
  }
}

