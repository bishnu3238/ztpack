import 'dart:developer' as dev;
import 'package:pack/pack.dart';

import 'api_responce.dart';

/// Base class for all API responses
/// Generic type parameters:
/// - T: The type of the data contained in the response
/// - E: The type of error data (defaults to Map<String, dynamic>)
abstract class BaseApiResponse<T, E extends Object> {
  final int status;
  final String message;
  final bool success;
  final Map<String, dynamic>? rawData;
  final String timestamp;

  const BaseApiResponse({
    required this.status,
    required this.message,
    required this.success,
    this.rawData,
    required this.timestamp,
  });

  /// Factory constructor to be implemented by subclasses
  factory BaseApiResponse.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }

  /// Helper method to check if response is successful
  bool get isSuccess => success || (status >= 200 && status < 300);

  /// Helper method to convert response to JSON
  Map<String, dynamic> toJson();

  /// Logs the response for debugging purposes
  void logResponse() {
    dev.log('Response: ${toJson()}');
  }
}

/// Standard API response for simple success/error responses
class StandardApiResponse extends BaseApiResponse<Map<String, dynamic>, Map<String, dynamic>> {
  final Map<String, dynamic>? data;

  const StandardApiResponse({
    required super.status,
    required super.message,
    required super.success,
    this.data,
    super.rawData,
    required super.timestamp,
  });

  factory StandardApiResponse.fromJson(Map<String, dynamic> json) {
    return StandardApiResponse(
      status: json.getInt('status', 200),
      message: json.getString('message', ''),
      success: json.getBool('success', json.getInt('status', 200) >= 200 && json.getInt('status', 200) < 300),
      data: json['data'] as Map<String, dynamic>?,
      rawData: json,
      timestamp: json.getString('timestamp', DateTime.now().toIso8601String()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'success': success,
      'data': data,
      'timestamp': timestamp,
    };
  }
}

/// Generic data response for handling lists of items
class DataListApiResponse<T> extends BaseApiResponse<List<T>, Map<String, dynamic>> {
  final List<T> items;
  final int count;
  final int? page;
  final int? totalPages;

  const DataListApiResponse({
    required super.status,
    required super.message,
    required super.success,
    required this.items,
    required this.count,
    this.page,
    this.totalPages,
    super.rawData,
    required super.timestamp,
  });

  factory DataListApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final dataList = json['data'] is List
        ? (json['data'] as List).map((item) => fromJsonT(item as Map<String, dynamic>)).toList()
        : <T>[];

    return DataListApiResponse<T>(
      status: json.getInt('status', 200),
      message: json.getString('message', ''),
      success: json.getBool('success', json.getInt('status', 200) >= 200 && json.getInt('status', 200) < 300),
      items: dataList,
      count: json.getInt('count', dataList.length),
      page: json['page'] != null ? json.getInt('page') : null,
      totalPages: json['total_pages'] != null ? json.getInt('total_pages') : null,
      rawData: json,
      timestamp: json.getString('timestamp', DateTime.now().toIso8601String()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'success': success,
      'count': count,
      if (page != null) 'page': page,
      if (totalPages != null) 'total_pages': totalPages,
      'timestamp': timestamp,
      // Note: items are not included as they would require a toJson method
    };
  }
}

/// Single data item response for handling individual objects
class DataItemApiResponse<T> extends BaseApiResponse<T, Map<String, dynamic>> {
  final T? data;

  const DataItemApiResponse({
    required super.status,
    required super.message,
    required super.success,
    this.data,
    super.rawData,
    required super.timestamp,
  });

  factory DataItemApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return DataItemApiResponse<T>(
      status: json.getInt('status', 200),
      message: json.getString('message', ''),
      success: json.getBool('success', json.getInt('status', 200) >= 200 && json.getInt('status', 200) < 300),
      data: json['data'] != null ? fromJsonT(json['data'] as Map<String, dynamic>) : null,
      rawData: json,
      timestamp: json.getString('timestamp', DateTime.now().toIso8601String()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'success': success,
      'data': data, // Note: This assumes T has a toJson method or is serializable
      'timestamp': timestamp,
    };
  }
}

/// Response type with multi-state pattern for login flows or complex state handling
/// Similar to your MerchantLoginResponse
class MultiStateApiResponse<T, E extends Object> extends BaseApiResponse<T, E> {
  final ResponseState state;
  final T? data;
  final E? error;

  const MultiStateApiResponse({
    required super.status,
    required super.message,
    required super.success,
    required this.state,
    this.data,
    this.error,
    super.rawData,
    required super.timestamp,
  });

  factory MultiStateApiResponse.success({
    required int status,
    required String message,
    required T data,
    required String timestamp,
  }) {
    return MultiStateApiResponse<T, E>(
      status: status,
      message: message,
      success: true,
      state: ResponseState.success,
      data: data,
      timestamp: timestamp,
    );
  }

  factory MultiStateApiResponse.error({
    required int status,
    required String message,
    E? error,
    required String timestamp,
  }) {
    return MultiStateApiResponse<T, E>(
      status: status,
      message: message,
      success: false,
      state: ResponseState.error,
      error: error,
      timestamp: timestamp,
    );
  }

  factory MultiStateApiResponse.loading({
    String message = 'Loading...',
    required String timestamp,
  }) {
    return MultiStateApiResponse<T, E>(
      status: 0,
      message: message,
      success: false,
      state: ResponseState.loading,
      timestamp: timestamp,
    );
  }

  factory MultiStateApiResponse.intermediate({
    required int status,
    required String message,
    Map<String, dynamic>? intermediateData,
    required String timestamp,
  }) {
    return MultiStateApiResponse<T, E>(
      status: status,
      message: message,
      success: true,
      state: ResponseState.intermediate,
      rawData: intermediateData,
      timestamp: timestamp,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'success': success,
      'state': state.toString(),
      if (data != null) 'data': data,
      if (error != null) 'error': error,
      'timestamp': timestamp,
    };
  }

  /// Helper method similar to when() in your MerchantLoginResponse
  R when<R>({
    required R Function(T data) success,
    required R Function(E? error) error,
    R Function()? loading,
    R Function(Map<String, dynamic>? data)? intermediate,
  }) {
    switch (state) {
      case ResponseState.success:
        return success(data as T);
      case ResponseState.error:
        return error(error as E?);
      case ResponseState.loading:
        return loading?.call() ?? error(null);
      case ResponseState.intermediate:
        return intermediate?.call(rawData) ?? error(null);
    }
  }
}

/// Enum for different response states in the MultiStateApiResponse
enum ResponseState {
  success,
  error,
  loading,
  intermediate,
}

/// Extension for easy conversion of ApiResponse to BaseApiResponse
extension ApiResponseConverter on ApiResponse {
  StandardApiResponse toStandardApiResponse() {
    final responseData = data is Map<String, dynamic> ? data as Map<String, dynamic> : {'data': data};

    return StandardApiResponse(
      status: statusCode,
      message: responseData['message'] ?? '',
      success: isSuccess,
      data: responseData,
      timestamp: timestamp.toIso8601String(),
    );
  }

  DataListApiResponse<T> toDataListApiResponse<T>(T Function(Map<String, dynamic>) fromJsonT) {
    final responseData = data as Map<String, dynamic>;
    final items = responseData['data'] is List
        ? (responseData['data'] as List).map((item) => fromJsonT(item as Map<String, dynamic>)).toList()
        : <T>[];

    return DataListApiResponse<T>(
      status: statusCode,
      message: responseData['message'] ?? '',
      success: isSuccess,
      items: items,
      count: responseData['count'] ?? items.length,
      page: responseData['page'],
      totalPages: responseData['total_pages'],
      timestamp: timestamp.toIso8601String(),
    );
  }

  DataItemApiResponse<T> toDataItemApiResponse<T>(T Function(Map<String, dynamic>) fromJsonT) {
    final responseData = data as Map<String, dynamic>;

    return DataItemApiResponse<T>(
      status: statusCode,
      message: responseData['message'] ?? '',
      success: isSuccess,
      data: responseData['data'] != null ? fromJsonT(responseData['data'] as Map<String, dynamic>) : null,
      timestamp: timestamp.toIso8601String(),
    );
  }
}