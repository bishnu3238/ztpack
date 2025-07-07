import 'package:dartz/dartz.dart';
import '../../../../services/failure/src/network_failure.dart';
import '../../data/models/auth_response.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository<T extends UserEntity> {

  Future<Either<NetworkFailure, LoginResponse<T>>> login(
    String emailOrUsername,
    String password,
  );

  Future<Either<NetworkFailure, SignupResponse<T>>> signup(
    String email,
    String phone,
    String password, {
    String? name,
  });
  Future<Either<NetworkFailure, bool>> sendOTP(String phoneNo);
  Future<Either<NetworkFailure, bool>> sendEmail(String email);

  Future<Either<NetworkFailure, OtpVerifyResponse<T>>> verifyOTP({
    required String userId,
    required String otp,
  });
  Future<Either<NetworkFailure, bool>> resetPassword(
    String resetToken,
    String newPassword,
    String confirmPassword,
  );
  Future<Either<NetworkFailure, ForgotPasswordResponse<T>>> forgotPassword(String email);

  Future<Either<NetworkFailure, ChangePasswordResponse<T>>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  );
  Future<Either<NetworkFailure, AuthResponse<T>>> socialLogin(
    String provider,
    String token, {
    Map<String, dynamic>? userData,
  });
  Future<Either<NetworkFailure, bool>> logout();
  Future<T?> getCurrentUser();
  Future<bool> isAuthenticated();
}
