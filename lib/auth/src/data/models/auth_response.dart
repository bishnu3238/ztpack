// src/data/models/auth_response.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:pack/services/api_services/src/log_service.dart';
import 'package:pack/services/failure/failure.dart';

import '../../../custom_auth.dart';
import 'dart:developer' as dev;

import 'signup_request.dart';

// src/data/models/auth_type.dart
enum AuthType { login, signup, otpVerification, forgotPassword, resetPassword }

abstract class AuthResponse<T extends UserEntity> {
  final T? user;
  final String? status;
  final String? message;
  AuthResponse({required this.user, this.message, this.status});

  @override
  String toString() {
    return 'AuthResponse{user: $user}';
  }
}

class LoginResponse<T extends UserEntity> extends AuthResponse<T> {
  final String? token;

  LoginResponse({
    required this.token,
    required super.user,
    super.message,
    super.status,
  });

  factory LoginResponse.convert(data) {
    Logger().i('$data');
    dev.log('Login Response Convert: $data');
    return LoginResponse(
      user: getIt.get<UserConvert<T>>().call(data),
      token: '${data['data']['user']['id']}',
      status: data['status'],
      message: data['message'],
    );
  }

  @override
  String toString() {
    return 'LoginResponse{token: $token, user: $user}';
  }
}

class SignupResponse<T extends UserEntity> extends AuthResponse<T> {
  final String otp;
  final String userId;
  final SignupRequest? request;
  SignupResponse({
    required this.otp,
    required this.userId,
    this.request,
    super.user,
    super.message,
    super.status,
  });

  factory SignupResponse.convert(Map<String, dynamic> data) {
    dev.log('SignupResponse convert:= $data');
    return SignupResponse(
      otp: data.containsKey('data') ? data['data']['otp'] : '',
      userId: data.containsKey('data') ? data['data']['user_id'] : '',
      user: null,
      status: data['status'],
      message: data['message'],
    );
  }

  SignupResponse<T> copyWith({
    String? otp,
    String? userId,
    SignupRequest? request,
    T? user,
    String? status,
    String? message,
  }) => SignupResponse<T>(
    otp: otp ?? this.otp,
    userId: userId ?? this.userId,
    message: message ?? this.message,
    status: status ?? this.status,
    user: user ?? this.user,
  );
}

class OtpVerifyResponse<T extends UserEntity> extends AuthResponse<T> {
  final String token;
  final bool isOTPVerify;

  OtpVerifyResponse({
    super.user,
    required this.token,
    required this.isOTPVerify,
    super.message,
    super.status,
  });

  factory OtpVerifyResponse.convert(data) {
    LogService().info('$data');
    dev.log('OtpVerifyResponse.convert: $data');
    return OtpVerifyResponse(
      user: getIt.get<UserConvert<T>>().call(data),
      token: data['data']['token'],
      isOTPVerify: data['user'] != null ? true : false,
      status: data['status'],
      message: data['message'],
    );
  }
}

class ChangePasswordResponse<T extends UserEntity> extends AuthResponse<T> {
  final String token;
  final String isChange;
  ChangePasswordResponse({
    required this.token,
    required this.isChange,
    required super.user,
  });

  factory ChangePasswordResponse.convert(data) {
    LogService().info('$data');
    dev.log('$data');
    return ChangePasswordResponse(
      user: getIt.get<UserConvert<T>>().call(data['data']['user']),
      isChange: data['value'] ?? true,

      token: data['token'],
    );
  }
}

// Add this class within your src/data/models/auth_response.dart file
// or wherever the other AuthResponse classes are defined.

class ForgotPasswordResponse<T extends UserEntity> extends AuthResponse<T> {
  final String? otp, userId;
  final bool? smsSent;

  ForgotPasswordResponse({
    this.otp,
    this.userId,
    this.smsSent,
    super.user,
    super.message,
    super.status,
  });

  factory ForgotPasswordResponse.convert(Map<String, dynamic> data) {
    dev.log('ForgotPasswordResponse convert: $data');

    final responseData =
        data.containsKey('data') && data['data'] is Map
            ? data['data'] as Map<String, dynamic>
            : null;

    return ForgotPasswordResponse(
      otp: responseData?['otp']?.toString(), // Use null-aware access
      userId: responseData?['user_id']?.toString(), // Use null-aware access

      smsSent:
          responseData?['sms_sent'] as bool?, // Cast to bool?, handles null

      user: null,

      status: data['status']?.toString(),
      message: data['message']?.toString(),
    );
  }

  @override
  String toString() {
    return 'ForgotPasswordResponse{otp: $otp, smsSent: $smsSent, status: $status, message: $message, user: $user}';
  }
}

//  class AuthResponse<T extends UserEntity> {
//   final AuthType type;
//   final T? user;
//   final String? token;
//   final String? refreshToken;
//   final DateTime? expiresAt;
//   final String? userId;
//   final String? otp;
//
//   AuthResponse({
//     required this.type,
//       this.user,
//     this.token,
//     this.refreshToken,
//     this.expiresAt,
//     this.userId,
//     this.otp,
//   });
//
//   factory AuthResponse.fromJson(
//     T user,
//     ApiResponse<Map<String, dynamic>> data,
//   ) {
//     return AuthResponse<T>(
//       user: user,
//       token: data.data!['token'],
//       refreshToken: data.data!['refresh_token'],
//       expiresAt:
//           data.data!['expires_at'] != null
//               ? DateTime.parse(data.data!['expires_at'])
//               : null,
//       type: AuthType.login,
//       userId: data.data!['user_id']?.toString(),
//       otp: data.data!['otp'],
//     );
//   }
//
//   factory AuthResponse.converter(
//     json,
//     Function(Map<String, dynamic> p1) userFromJson,
//   ) {
//     Map<String, dynamic> data = json['data'];
//
//     return AuthResponse<T>(
//       user: data['user'] != null ? userFromJson(data) : null,
//       token: data['token'],
//       refreshToken: data['refresh_token'],
//       expiresAt:
//           data['expires_at'] != null
//               ? DateTime.parse(data['expires_at'])
//               : null,
//       type: AuthType.login,
//       userId: data['user_id']?.toString(),
//       otp: data['otp'],
//     );
//   }
//
//   factory AuthResponse.fromMap(Map<String, dynamic> json, AuthType type, Function(Map<String, dynamic>) userFromJson) {
//     Map<String, dynamic> data = json['data'] ?? json;
//
//     return AuthResponse(
//       type: type,
//       user: data['user'] != null ? userFromJson(data) : null,
//       token: data['token'],
//       refreshToken: data['refresh_token'],
//       expiresAt: data['expires_at'] != null
//           ? DateTime.parse(data['expires_at'])
//           : null,
//       userId: data['user_id']?.toString(),
//       otp: data['otp'],
//     );
//   }
// }

// Type alias for functional programming
typedef AuthResult = Either<AuthFailure, AuthResponse>;
