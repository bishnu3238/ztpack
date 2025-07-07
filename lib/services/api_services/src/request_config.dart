import 'dart:developer' as dev;
import 'dart:io';

import 'package:dio/dio.dart';

/// Request configuration
class RequestConfig {
  final String baseUrl;
  final String endpoint;
  final RequestMethod method;
  final Map<String, dynamic>? queryParameters;
  final Map<String, String>? headers;
  final dynamic body;
  final ResponseFormat responseFormat;
  final Duration timeout;
  final bool requiresAuth;
  final CachePolicy cachePolicy;
  final String? cacheKey;
  final Duration cacheDuration;
  final bool retryEnabled;
  final int maxRetries;
  final Function(int sent, int total)? onSendProgress;
  final Function(int received, int total)? onReceiveProgress;
  final String? requestId;
  final Duration? retryDelay;
  final dynamic Function(dynamic)? customResponseDecoder;

  RequestConfig({
    required this.baseUrl,
    required this.endpoint,
    this.method = RequestMethod.get,
    this.queryParameters,
    this.headers,
    this.body,
    this.responseFormat = ResponseFormat.json,
    this.timeout = const Duration(seconds: 30),
    this.requiresAuth = false,
    this.cachePolicy = CachePolicy.networkOnly,
    this.cacheKey,
    this.cacheDuration = const Duration(minutes: 5),
    this.retryEnabled = false,
    this.maxRetries = 3,
    this.onSendProgress,
    this.onReceiveProgress,
    this.requestId,
    this.retryDelay,
    this.customResponseDecoder,
  });

  String get fullUrl => '$baseUrl$endpoint';

  Map<String, String> get headersMap =>
      (headers ?? {}).map((key, value) => MapEntry(key, value.toString()));

  RequestConfig.forFileUpload({
    required String baseUrl,
    required String endpoint,
    required Map<String, dynamic> files, // e.g., {'file': File('path/to/file')}
    Map<String, String>? fields, // Additional form fields
    RequestMethod method = RequestMethod.post,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    bool requiresAuth = false,
    CachePolicy cachePolicy =
        CachePolicy.noCache, // Usually no cache for uploads
    Function(int sent, int total)? onSendProgress,
  }) : this(
         baseUrl: baseUrl,
         endpoint: endpoint,
         method: method,
         headers: headers ?? {'Content-Type': 'multipart/form-data'},
         body: _createFormData(files, fields),
         timeout: timeout,
         requiresAuth: requiresAuth,
         cachePolicy: cachePolicy,
         onSendProgress: onSendProgress,
       );

  static FormData _createFormData(
    Map<String, dynamic> files,
    Map<String, String>? fields,
  ) {
    final formData = FormData();
    files.forEach((key, file) {
      dev.log("File: $key, $file");
      if (file is File) {
        formData.files.add(
          MapEntry(
            key,
            MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    });
    if (fields != null) {
      formData.fields.addAll(fields.entries);
    }

    return formData;
  }

  @override
  String toString() {
    return 'RequestConfig{baseUrl: $baseUrl, endpoint: $endpoint, method: $method, queryParameters: $queryParameters, headers: $headers, body: $body, responseFormat: $responseFormat, timeout: $timeout, requiresAuth: $requiresAuth, cachePolicy: $cachePolicy, cacheKey: $cacheKey, cacheDuration: $cacheDuration, retryEnabled: $retryEnabled, maxRetries: $maxRetries, onSendProgress: $onSendProgress, onReceiveProgress: $onReceiveProgress, requestId: $requestId, retryDelay: $retryDelay, customResponseDecoder: $customResponseDecoder}';
  }
}

/// Represents possible request methods
enum RequestMethod { get, post, put, patch, delete }

/// Represents possible response formats
enum ResponseFormat { json, plain, bytes, stream }

/// Cache policy options
enum CachePolicy {
  noCache,
  useCache,
  cacheFirst,
  networkFirst,
  cacheOnly,
  networkOnly,
}
