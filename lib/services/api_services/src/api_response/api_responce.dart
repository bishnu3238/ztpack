/// Response wrapper
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final Map<String, String>? headers;
  final bool isFromCache;
  final DateTime timestamp;
  final dynamic error;

  ApiResponse({
    this.data,
    required this.statusCode,
    this.headers,
    this.isFromCache = false,
    DateTime? timestamp,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse<T>(
        data: json['data'],
        statusCode: json['statusCode'],
        headers: json['headers'] != null ? Map<String, String>.from(json['headers']) : null,
        isFromCache: json['isFromCache'] ?? false,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {
        'data': data,
        'statusCode': statusCode,
        'headers': headers,
        'isFromCache': isFromCache,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
      };
}