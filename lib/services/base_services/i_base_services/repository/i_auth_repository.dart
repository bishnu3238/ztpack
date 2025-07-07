import 'package:dartz/dartz.dart';

import '../../../failure/src/auth_failure.dart';
import '../../base_model.dart';
import 'i_repository.dart';

/// Interface for auth repository with specific methods
abstract class IAuthRepository<T extends BaseModel> implements IRepository {
  Future<Either<AuthFailure, T>> login(LoginRequest request);
  Future<Either<AuthFailure, T>> register(RegisterRequest request);
  Future<Either<AuthFailure, T>> verifyOTP(VerifyOTPRequest request);
  Future<Either<AuthFailure, T>> resendOTP(ResendOTPRequest request);
  Future<Either<AuthFailure, T>> verifyEmail(VerifyEmailRequest request);
  Future<Either<AuthFailure, T>> resetPassword(ResetPasswordRequest request);
  Future<Either<AuthFailure, T>> forgotPassword(ForgotPasswordRequest request);
  Future<Either<AuthFailure, T>> changePassword(ChangePasswordRequest request);
  Future<bool> logout();
  Future<T> getUserProfile([String? userId]);
  Future<R> getUserPreferences<R extends IBaseModel>([String? userId]);
  Future<R> updateUserPreferences<R extends IBaseModel>(R preferences);
}

/// User preferences model
abstract class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

abstract class RegisterRequest {
  final String username;
  final String email;
  final String password;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
  };
}

abstract class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

abstract class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({required this.oldPassword, required this.newPassword});

  Map<String, dynamic> toJson() => {
    'old_password': oldPassword,
    'new_password': newPassword,
  };
}

abstract class ResetPasswordRequest {
  final String email;

  ResetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

abstract class VerifyEmailRequest {
  final String email;

  VerifyEmailRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

abstract class VerifyOTPRequest {
  final String otp;
  final String userId;

  VerifyOTPRequest({required this.otp, required this.userId});

  Map<String, dynamic> toJson() => {'otp': otp, 'user_id': userId};
}

abstract class UserPreferencesRequest {
  final String theme;
  final String language;

  UserPreferencesRequest({required this.theme, required this.language});

  Map<String, dynamic> toJson() => {'theme': theme, 'language': language};
}

abstract class ResendOTPRequest {
  final String id;

  ResendOTPRequest({required this.id});

  Map<String, dynamic> toJson() => {'id': id};
}
