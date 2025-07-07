import 'dart:developer' as dev;
import 'dart:async';
import '../failure.dart';

/// Comprehensive network error types covering all edge cases
enum NetworkErrorType {
  badRequest, // 400: Invalid request
  unauthorized, // 401: Authentication failed
  forbidden, // 403: Access denied
  notFound, // 404: Resource not found
  timeout, // Request timed out
  serverError, // 500: Server-side issue
  noInternet, // No connectivity
  parseError, // JSON/data parsing failed
  cancelled, // Request cancelled by user/app
  unknown, // Unclassified error
  rateLimitExceeded, // 429: Too many requests
  badGateway, // 502: Gateway issue
  serviceUnavailable, // 503: Service down
  conflict, // 409: Resource conflict
  tooLarge, // 413: Payload too large
}

/// Retry policy for network failures
enum RetryPolicy {
  none, // No retries
  linear, // Fixed delay between retries
  exponential, // Exponential backoff
  immediate, // Retry immediately
}

class NetworkFailure extends Failure {
  final int? statusCode;
  final dynamic data;
  final StackTrace? stackTrace;
  final NetworkErrorType type;
  final DateTime timestamp;
  final int retryCount;
  final RetryPolicy retryPolicy; // New: Configurable retry strategy
  final int maxRetries; // New: Maximum retry attempts
  final Duration? retryDelay; // New: Delay between retries
  final bool isRetriable; // New: Can this be retried?
  final String? suggestedAction; // New: User-facing suggestion

  NetworkFailure({
    required super.message,
    this.statusCode,
    String? code,
    super.originalError,
    this.data,
    this.stackTrace,
    this.type = NetworkErrorType.unknown,
    this.retryCount = 0,
    this.retryPolicy = RetryPolicy.none,
    this.maxRetries = 3,
    this.retryDelay,
    this.isRetriable = false,
    this.suggestedAction,
  }) : timestamp = DateTime.now(),
       super(code: code ?? 'NETWORK_ERROR_${statusCode ?? 'UNKNOWN'}') {
    dev.log(toString(), name: 'NetworkFailure');
  }

  // Factory constructors for common scenarios
  factory NetworkFailure.noConnection() => NetworkFailure(
    message: 'No internet connection detected',
    type: NetworkErrorType.noInternet,
    isRetriable: true,
    retryPolicy: RetryPolicy.linear,
    retryDelay: const Duration(seconds: 5),
    suggestedAction: 'Please check your internet connection and try again',
  );

  factory NetworkFailure.timeout({int timeoutSeconds = 30}) => NetworkFailure(
    message: 'Request timed out after $timeoutSeconds seconds',
    type: NetworkErrorType.timeout,
    isRetriable: true,
    retryPolicy: RetryPolicy.exponential,
    retryDelay: const Duration(seconds: 2),
    suggestedAction: 'Please try again later',
  );

  factory NetworkFailure.serverError(
    int statusCode, {
    dynamic originalError,
    dynamic data,
  }) => NetworkFailure(
    message: 'Server error occurred: $statusCode',
    statusCode: statusCode,
    type: _mapStatusCodeToType(statusCode),
    originalError: originalError,
    data: data,
    isRetriable: statusCode >= 500 && statusCode < 600,
    retryPolicy: RetryPolicy.exponential,
    retryDelay: const Duration(seconds: 3),
    suggestedAction: 'Server issue detected. Please wait and retry.',
  );

  factory NetworkFailure.rateLimitExceeded(int retryAfterSeconds) =>
      NetworkFailure(
        message: 'Too many requests. Retry after $retryAfterSeconds seconds',
        statusCode: 429,
        type: NetworkErrorType.rateLimitExceeded,
        data: {'retryAfter': retryAfterSeconds},
        isRetriable: true,
        retryPolicy: RetryPolicy.linear,
        retryDelay: Duration(seconds: retryAfterSeconds),
        suggestedAction: 'Please wait before trying again',
      );

  factory NetworkFailure.fromResponse(
    int statusCode, {
    dynamic data,
    dynamic error,
  }) {
    switch (statusCode) {
      case 400:
        return NetworkFailure.badRequest(data: data);
      case 401:
        return NetworkFailure.unauthorized(data: data);
      case 403:
        return NetworkFailure.forbidden(data: data);
      case 404:
        return NetworkFailure.notFound(data: data);
      case 409:
        return NetworkFailure.conflict(data: data);
      case 413:
        return NetworkFailure.tooLarge(data: data);
      case 429:
        return NetworkFailure.rateLimitExceeded(data['retryAfter'] ?? 60);
      case 502:
        return NetworkFailure.badGateway(data: data);
      case 503:
        return NetworkFailure.serviceUnavailable(data: data);
      default:
        return NetworkFailure.serverError(
          statusCode,
          data: data,
          originalError: error,
        );
    }
  }

  // Specific error factories
  factory NetworkFailure.badRequest({dynamic data}) => NetworkFailure(
    message: 'Invalid request sent to server',
    statusCode: 400,
    type: NetworkErrorType.badRequest,
    data: data,
    suggestedAction: 'Please check your input and try again',
  );

  factory NetworkFailure.unauthorized({dynamic data}) => NetworkFailure(
    message: 'Authentication required',
    statusCode: 401,
    type: NetworkErrorType.unauthorized,
    data: data,
    suggestedAction: 'Please log in again',
  );

  factory NetworkFailure.forbidden({dynamic data}) => NetworkFailure(
    message: 'Access denied to this resource',
    statusCode: 403,
    type: NetworkErrorType.forbidden,
    data: data,
    suggestedAction: 'Contact support if this is unexpected',
  );

  factory NetworkFailure.notFound({dynamic data}) => NetworkFailure(
    message: 'Requested resource not found',
    statusCode: 404,
    type: NetworkErrorType.notFound,
    data: data,
    suggestedAction: 'Check the URL or resource ID',
  );

  factory NetworkFailure.conflict({dynamic data}) => NetworkFailure(
    message: 'Resource conflict detected',
    statusCode: 409,
    type: NetworkErrorType.conflict,
    data: data,
    suggestedAction: 'Resolve the conflict and try again',
  );

  factory NetworkFailure.tooLarge({dynamic data}) => NetworkFailure(
    message: 'Payload too large for server to process',
    statusCode: 413,
    type: NetworkErrorType.tooLarge,
    data: data,
    suggestedAction: 'Reduce the size of your request and try again',
  );

  factory NetworkFailure.badGateway({dynamic data}) => NetworkFailure(
    message: 'Bad gateway error from server',
    statusCode: 502,
    type: NetworkErrorType.badGateway,
    data: data,
    suggestedAction: 'Please try again later',
  );

  factory NetworkFailure.serviceUnavailable({dynamic data}) => NetworkFailure(
    message: 'Service is currently unavailable',
    statusCode: 503,
    type: NetworkErrorType.serviceUnavailable,
    data: data,
    suggestedAction: 'Please try again later',
  );

  // Utility methods
  NetworkFailure withRetry() => NetworkFailure(
    message: message,
    statusCode: statusCode,
    code: code,
    originalError: originalError,
    data: data,
    stackTrace: stackTrace,
    type: type,
    retryCount: retryCount + 1,
    retryPolicy: retryPolicy,
    maxRetries: maxRetries,
    retryDelay: retryDelay,
    isRetriable: isRetriable && retryCount < maxRetries,
    suggestedAction: suggestedAction,
  );

  Future<void> retry(Future Function() operation) async {
    if (!isRetriable || retryCount >= maxRetries) throw this;
    await Future.delayed(retryDelay ?? Duration.zero);
    try {
      await operation();
    } catch (e) {
      throw withRetry();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'message': message,
    'code': code,
    'statusCode': statusCode,
    'type': type.toString(),
    'retryCount': retryCount,
    'timestamp': timestamp.toIso8601String(),
    'data': data?.toString(),
    'suggestedAction': suggestedAction,
  };

  static NetworkErrorType _mapStatusCodeToType(int statusCode) {
    switch (statusCode) {
      case 400:
        return NetworkErrorType.badRequest;
      case 401:
        return NetworkErrorType.unauthorized;
      case 403:
        return NetworkErrorType.forbidden;
      case 404:
        return NetworkErrorType.notFound;
      case 409:
        return NetworkErrorType.conflict;
      case 413:
        return NetworkErrorType.tooLarge;
      case 429:
        return NetworkErrorType.rateLimitExceeded;
      case 502:
        return NetworkErrorType.badGateway;
      case 503:
        return NetworkErrorType.serviceUnavailable;
      default:
        return statusCode >= 500
            ? NetworkErrorType.serverError
            : NetworkErrorType.unknown;
    }
  }

  @override
  String toString() =>
      'NetworkFailure => statusCode: $statusCode, type: $type, '
      'retryCount: $retryCount, timestamp: $timestamp, data: $data';
}

extension NetworkFailureExtension on NetworkFailure {
  bool get isRetriable => retryPolicy != RetryPolicy.none && isRetriable;
  bool get isServerError => type == NetworkErrorType.serverError;
  bool get isClientError =>
      type == NetworkErrorType.badRequest ||
      type == NetworkErrorType.unauthorized;
  bool get isTimeout => type == NetworkErrorType.timeout;

  AuthFailure get authFailure => AuthFailure(
    message: message,
    code: code,
    isCritical: true,
    state:
        type == NetworkErrorType.notFound
            ? AuthState.invalid
            : type == NetworkErrorType.unauthorized
            ? AuthState.unknown
            : AuthState.expired,
    suggestedAction: data,
    lockoutDuration: timestamp.timeZoneOffset,
  );
}
