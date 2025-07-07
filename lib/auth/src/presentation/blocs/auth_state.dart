// States
import '../../data/models/auth_response.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState<T extends UserEntity> {}

class AuthInitialState<T extends UserEntity> extends AuthState<T> {}

class AuthLoadingState<T extends UserEntity> extends AuthState<T> {}

class AuthenticatedState<T extends UserEntity> extends AuthState<T> {
  final AuthResponse<T> authResponse;

  AuthenticatedState(this.authResponse);
}

class UnauthenticatedState<T extends UserEntity> extends AuthState<T> {}

class OTPSentState<T extends UserEntity> extends AuthState<T> {
  final String userId;
  final String otp;
  OTPSentState(this.userId, this.otp);
}

class OTPRequestedState<T extends UserEntity> extends AuthState<T> {}

class OTPVerifiedState<T extends UserEntity> extends AuthState<T> {
  final String resetToken;
  OTPVerifiedState(this.resetToken);
}

class PasswordResetState<T extends UserEntity> extends AuthState<T> {}

class AuthErrorState<T extends UserEntity> extends AuthState<T> {
  final String message;
  AuthErrorState(this.message);
}

class PasswordResetSentState<T extends UserEntity> extends AuthState<T> {

  final String? message;
  final String userId;
  final String otp;
    PasswordResetSentState({this.message,required this.userId,required this.otp});

}

class PasswordChangedState<T extends UserEntity> extends AuthState<T> {}
