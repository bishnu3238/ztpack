import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:async';

import 'package:flutter/material.dart';

enum ErrorSeverity {
  critical, // App cannot continue, requires immediate attention
  major, // Feature completely blocked
  moderate, // Partial functionality affected
  minor, // Minor inconvenience, app can still function
  warning, // Just a warning, doesn't affect functionality
}

// Base state class to manage UI states
abstract class ViewState {}

class LoadingState extends ViewState {}

class DataState<T> extends ViewState {
  final T data;
  DataState(this.data);
}

// Enhanced error state with severity levels and recovery options
class ErrorState extends ViewState {
  // Error severity levels for appropriate UI treatment

  final String message;
  final String? technicalDetails;
  final ErrorSeverity severity;
  final dynamic originalException;
  final StackTrace? stackTrace;
  final bool userVisible;
  final String errorCode;
  final Map<String, dynamic>? metadata;

  // Recovery options
  final bool isRetryable;
  final VoidCallback? retryCallback;
  final bool isDismissible;
  final String? actionLabel;
  final VoidCallback? actionCallback;

  // Error tracking
  final DateTime timestamp;
  final String errorId;

  ErrorState({
    required this.message,
    this.technicalDetails,
    this.severity = ErrorSeverity.moderate,
    this.originalException,
    this.stackTrace,
    this.userVisible = true,
    this.errorCode = 'ERR_UNKNOWN',
    this.metadata,
    this.isRetryable = false,
    this.retryCallback,
    this.isDismissible = true,
    this.actionLabel,
    this.actionCallback,
  }) : timestamp = DateTime.now(),
       errorId = DateTime.now().millisecondsSinceEpoch.toString();

  // Factory constructors for common error scenarios
  factory ErrorState.network(String message, {VoidCallback? retryCallback}) {
    return ErrorState(
      message: message,
      technicalDetails: 'Network connectivity issue detected',
      severity: ErrorSeverity.major,
      errorCode: 'ERR_NETWORK',
      isRetryable: true,
      retryCallback: retryCallback,
      metadata: {'type': 'connectivity'},
    );
  }

  factory ErrorState.timeout(String message, {VoidCallback? retryCallback}) {
    return ErrorState(
      message: message,
      technicalDetails: 'Request timeout',
      severity: ErrorSeverity.moderate,
      errorCode: 'ERR_TIMEOUT',
      isRetryable: true,
      retryCallback: retryCallback,
      metadata: {'type': 'timeout'},
    );
  }

  factory ErrorState.validation(
    String message,
    Map<String, String> validationErrors,
  ) {
    return ErrorState(
      message: message,
      severity: ErrorSeverity.minor,
      errorCode: 'ERR_VALIDATION',
      metadata: {'validationErrors': validationErrors},
    );
  }

  factory ErrorState.serverError(String message, int statusCode) {
    return ErrorState(
      message: message,
      technicalDetails: 'Server responded with status code: $statusCode',
      severity:
          statusCode >= 500 ? ErrorSeverity.major : ErrorSeverity.moderate,
      errorCode: 'ERR_SERVER_$statusCode',
      isRetryable: statusCode >= 500,
      metadata: {'statusCode': statusCode},
    );
  }

  factory ErrorState.unauthorized() {
    return ErrorState(
      message: 'Your session has expired. Please log in again.',
      severity: ErrorSeverity.major,
      errorCode: 'ERR_AUTH',
      isRetryable: false,
      actionLabel: 'Log In',
      metadata: {'authRequired': true},
    );
  }

  // Logging and analytics helper
  Map<String, dynamic> toAnalyticsEvent() {
    return {
      'error_id': errorId,
      'error_code': errorCode,
      'message': message,
      'technical_details': technicalDetails,
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
      'retryable': isRetryable,
      'metadata': metadata,
      'exception': originalException?.toString(),
    };
  }

  // Copy with method for modifying error states
  ErrorState copyWith({
    String? message,
    String? technicalDetails,
    ErrorSeverity? severity,
    dynamic originalException,
    StackTrace? stackTrace,
    bool? userVisible,
    String? errorCode,
    Map<String, dynamic>? metadata,
    bool? isRetryable,
    VoidCallback? retryCallback,
    bool? isDismissible,
    String? actionLabel,
    VoidCallback? actionCallback,
  }) {
    return ErrorState(
      message: message ?? this.message,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      severity: severity ?? this.severity,
      originalException: originalException ?? this.originalException,
      stackTrace: stackTrace ?? this.stackTrace,
      userVisible: userVisible ?? this.userVisible,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
      isRetryable: isRetryable ?? this.isRetryable,
      retryCallback: retryCallback ?? this.retryCallback,
      isDismissible: isDismissible ?? this.isDismissible,
      actionLabel: actionLabel ?? this.actionLabel,
      actionCallback: actionCallback ?? this.actionCallback,
    );
  }

  // Helper to determine the appropriate UI representation
  Color get statusColor {
    switch (severity) {
      case ErrorSeverity.critical:
        return Colors.red.shade900;
      case ErrorSeverity.major:
        return Colors.red;
      case ErrorSeverity.moderate:
        return Colors.orange;
      case ErrorSeverity.minor:
        return Colors.amber;
      case ErrorSeverity.warning:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (severity) {
      case ErrorSeverity.critical:
        return Icons.error;
      case ErrorSeverity.major:
        return Icons.warning;
      case ErrorSeverity.moderate:
        return Icons.info;
      case ErrorSeverity.minor:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.help_outline;
      }
  }
}

// Error Handler to centralize error processing logic
class ErrorHandler {
  static ErrorState processException(
    dynamic exception, {
    StackTrace? stackTrace,
    VoidCallback? retryCallback,
    String fallbackMessage = 'An unexpected error occurred',
  }) {
    // Network errors
    if (exception is SocketException || exception is TimeoutException) {
      return ErrorState.network(
        'Unable to connect to servers. Please check your connection.',
        retryCallback: retryCallback,
      );
    }
    // HTTP errors
    else if (exception is DioException) {
      // Authentication errors
      if (exception.response?.statusCode == 401) {
        return ErrorState.unauthorized();
      }
      // Server errors
      else if (exception.response?.statusCode != null) {
        return ErrorState.serverError(
          'Server error (${exception.response!.statusCode})',
          exception.response!.statusCode!,
        );
      }
      // Request timeout
      else if (exception.type == DioExceptionType.connectionTimeout ||
          exception.type == DioExceptionType.receiveTimeout ||
          exception.type == DioExceptionType.sendTimeout) {
        return ErrorState.timeout(
          'Request timed out. Please try again.',
          retryCallback: retryCallback,
        );
      }
    }
    // Format/parsing errors
    else if (exception is FormatException) {
      return ErrorState(
        message: 'Invalid data format received from server',
        technicalDetails: exception.toString(),
        severity: ErrorSeverity.moderate,
        originalException: exception,
        stackTrace: stackTrace,
        errorCode: 'ERR_FORMAT',
        isRetryable: true,
        retryCallback: retryCallback,
      );
    }

    // Generic error fallback
    return ErrorState(
      message: fallbackMessage,
      technicalDetails: exception?.toString(),
      severity: ErrorSeverity.moderate,
      originalException: exception,
      stackTrace: stackTrace,
      errorCode: 'ERR_GENERIC',
      isRetryable: true,
      retryCallback: retryCallback,
    );
  }
}

// Base ViewModel with advanced error handling
abstract class BaseProviderModel extends ChangeNotifier {
  ViewState _state = LoadingState();

  // Add error tracking
  final List<ErrorState> _errorHistory = [];
  DateTime? _lastErrorTime;
  int _consecutiveErrorCount = 0;

  ViewState get state => _state;
  List<ErrorState> get errorHistory => List.unmodifiable(_errorHistory);

  bool get isLoading => _state is LoadingState;
  ErrorState? get currentError =>
      _state is ErrorState ? (_state as ErrorState) : null;

  void setLoading() {
    _state = LoadingState();
    notifyListeners();
  }

  void setError(ErrorState error) {
    _state = error;
    _trackError(error);
    notifyListeners();

    // Log error for analytics
    _logError(error);

    // Handle critical errors (e.g., show dialog, logout user)
    if (error.severity == ErrorSeverity.critical) {
      _handleCriticalError(error);
    }
  }

  // Process exception and convert to ErrorState
  void setException(
    dynamic exception, {
    StackTrace? stackTrace,
    VoidCallback? retryCallback,
    String fallbackMessage = 'An unexpected error occurred',
  }) {
    final errorState = ErrorHandler.processException(
      exception,
      stackTrace: stackTrace,
      retryCallback: retryCallback,
      fallbackMessage: fallbackMessage,
    );

    setError(errorState);
  }

  void setData<T>(T data) {
    _state = DataState<T>(data);
    _consecutiveErrorCount = 0;
    notifyListeners();
  }

  // Track error occurrences for advanced handling
  void _trackError(ErrorState error) {
    _errorHistory.add(error);
    if (_errorHistory.length > 10) {
      _errorHistory.removeAt(0);
    }

    // Track consecutive errors
    final now = DateTime.now();
    if (_lastErrorTime != null &&
        now.difference(_lastErrorTime!).inMinutes < 5) {
      _consecutiveErrorCount++;
    } else {
      _consecutiveErrorCount = 1;
    }
    _lastErrorTime = now;

    // Circuit breaker pattern - if too many consecutive errors occur
    if (_consecutiveErrorCount >= 5) {
      _triggerCircuitBreaker();
    }
  }

  void _logError(ErrorState error) {
    // Would integrate with your analytics/logging system
    print('ERROR [${error.errorCode}]: ${error.message}');
    print('Technical details: ${error.technicalDetails}');
    if (error.stackTrace != null) {
      print('Stack trace: ${error.stackTrace}');
    }
  }

  void _handleCriticalError(ErrorState error) {
    // Implement app-wide critical error handling
    // For example: show a modal dialog, force logout, etc.
  }

  void _triggerCircuitBreaker() {
    // Implement circuit breaker pattern
    // For example: pause all requests for a period, show systemic error message
    print('CIRCUIT BREAKER TRIGGERED: Too many consecutive errors');
  }

  // Reset errors and retry
  void retry() {
    if (currentError?.retryCallback != null) {
      currentError!.retryCallback!();
    }
  }

  // Clear current error state
  void clearError() {
    if (_state is ErrorState) {
      _state = LoadingState();
      notifyListeners();
    }
  }
}
