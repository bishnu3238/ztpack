// src/data/models/auth_error.dart
class AuthError {
  final String message;
  final String? code;
  final Map<String, dynamic>? data;

  AuthError({
    required this.message,
    this.code,
    this.data,
  });

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] ?? 'An unknown error occurred',
      code: json['code'],
      data: json['data'],
    );
  }
}