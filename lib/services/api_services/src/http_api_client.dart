import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../connectivity_service/connectivity_service.dart';
import '../../failure/src/network_failure.dart';
import 'api_response/api_responce.dart';
import 'auth_service.dart';
import 'base_api_client.dart';
import 'catch_service.dart';
import 'log_service.dart';
import 'request_config.dart';

/// HTTP client implementation of BaseApiClient using the http package
class HttpApiClient implements BaseApiClient {
  final http.Client _client;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  final AuthService _authService;
  final LogService _logger;
  final Map<String, Completer<void>> _cancelTokens = {};

  HttpApiClient({
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
       _client = http.Client() {
    // Set default timeout if provided (http doesn't have built-in timeout config)
    _defaultHeaders =
        defaultHeaders?.map((key, value) => MapEntry(key, value.toString())) ??
        {'Content-Type': 'application/json'};
  }

  Map<String, String> _defaultHeaders = {};

  @override
  Future<Either<NetworkFailure, ApiResponse<T>>> request<T>({
    required RequestConfig config,
    T Function(dynamic data)? responseConverter,
  }) async {
    final requestId = config.requestId ?? _generateRequestId(config);
    final completer = Completer<void>();
    _cancelTokens[requestId] = completer;

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

          if (config.cachePolicy == CachePolicy.cacheFirst) {
            _fetchAndCacheData(config, cacheKey, responseConverter);
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

    // Check connectivity
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

    // Prepare headers
    Map<String, String> headers = Map.from(_defaultHeaders);
    headers.addAll(config.headersMap);
    if (config.requiresAuth) {
      final authHeaders = await _authService.getAuthHeaders();
      headers.addAll(authHeaders);
    }

    try {
      // Prepare the request
      final uri = Uri.parse(config.fullUrl).replace(
        queryParameters: config.queryParameters?.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
      final body = config.body != null ? jsonEncode(config.body) : null;

      // Execute request with timeout
      final responseFuture = _executeRequest(
        config.method,
        uri,
        headers,
        body,
      ).timeout(config.timeout);

      // Handle cancellation
      final response = await Future.any([
        responseFuture,
        completer.future.then((_) => throw 'Request cancelled'),
      ]);

      // Process response
      final statusCode = response.statusCode;
      dynamic responseData;

      switch (config.responseFormat) {
        case ResponseFormat.json:
          responseData = jsonDecode(response.body);
          break;
        case ResponseFormat.plain:
          responseData = response.body;
          break;
        case ResponseFormat.bytes:
          responseData = response.bodyBytes;
          break;
        case ResponseFormat.stream:
          throw UnsupportedError('Stream not supported with http package');
      }

      final convertedData =
          responseConverter != null
              ? responseConverter(responseData)
              : config.customResponseDecoder != null
                  ? config.customResponseDecoder!(responseData) as T
                  : responseData as T;

      final apiResponse = ApiResponse<T>(
        data: convertedData,
        statusCode: statusCode,
        headers: response.headers,
      );

      // Cache if successful
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
    } on TimeoutException catch (e, stack) {
      _cancelTokens.remove(requestId);
      if (config.retryEnabled) {
        return await _retryRequest(config, responseConverter);
      }
      return left(
        NetworkFailure(
          message: 'Request timed out',
          type: NetworkErrorType.timeout,
          stackTrace: stack,
        ),
      );
    } on SocketException catch (e, stack) {
      _cancelTokens.remove(requestId);
      return left(
        NetworkFailure(
          message: 'Network error: ${e.message}',
          type: NetworkErrorType.noInternet,
          stackTrace: stack,
        ),
      );
    } catch (e, stack) {
      _cancelTokens.remove(requestId);
      if (e.toString() == 'Request cancelled') {
        return left(
          NetworkFailure(
            message: 'Request cancelled',
            type: NetworkErrorType.cancelled,
          ),
        );
      }
      return left(
        NetworkFailure(
          message: 'Unexpected error: ${e.toString()}',
          type: NetworkErrorType.unknown,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  void cancelRequests([String? requestId]) {
    if (requestId != null) {
      if (_cancelTokens.containsKey(requestId)) {
        _cancelTokens[requestId]!.complete();
        _cancelTokens.remove(requestId);
        _logger.debug('Cancelled request: $requestId');
      }
    } else {
      for (final completer in _cancelTokens.values) {
        completer.complete();
      }
      _cancelTokens.clear();
      _logger.debug('Cancelled all requests');
    }
  }

  @override
  Future<void> dispose() async {
    cancelRequests();
    _client.close();
    _logger.debug('Disposed HttpApiClient');
  }

  // Helper methods
  Future<http.Response> _executeRequest(
    RequestMethod method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) async {
    switch (method) {
      case RequestMethod.get:
        return await _client.get(uri, headers: headers);
      case RequestMethod.post:
        return await _client.post(uri, headers: headers, body: body);
      case RequestMethod.put:
        return await _client.put(uri, headers: headers, body: body);
      case RequestMethod.patch:
        return await _client.patch(uri, headers: headers, body: body);
      case RequestMethod.delete:
        return await _client.delete(uri, headers: headers, body: body);
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
}
