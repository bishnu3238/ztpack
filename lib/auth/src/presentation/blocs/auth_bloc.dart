// src/presentation/blocs/auth_bloc.dart
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// BLoC
class AuthBloc<T extends UserEntity> extends Bloc<AuthEvent, AuthState<T>> {
  final LoginUseCase<T> loginUseCase;
  final SignupUseCase<T> signupUseCase;
  final ForgotPasswordUseCase<T> forgotPasswordUseCase;
  final ChangePasswordUseCase<T> changePasswordUseCase;
  final LogoutUseCase<T> logoutUseCase;
  final SocialLoginUseCase<T>? socialLoginUseCase;
  final SendOTPUseCase<T> sendOTPUseCase;
  final VerifyOTPUseCase<T> verifyOTPUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.forgotPasswordUseCase,
    required this.changePasswordUseCase,
    required this.logoutUseCase,
    required this.sendOTPUseCase,
    required this.verifyOTPUseCase,
    required this.resetPasswordUseCase,
    this.socialLoginUseCase,
  }) : super(AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<SocialLoginEvent>(_onSocialLogin);
    on<LogoutEvent>(_onLogout);
    on<SendOTPEvent>(_onSendOTP);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState<T>> emit) async {
    emit(AuthLoadingState<T>());
    try {
      final authResponse = await loginUseCase.execute(
        event.emailOrUsername,
        event.password,
      );
      authResponse.fold(
        (failure) => emit(AuthErrorState<T>(failure.message)),
        (result) => emit(AuthenticatedState<T>(result)),
      );
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState<T>> emit) async {
    emit(AuthLoadingState<T>());
    try {
      final authResponse = await signupUseCase.execute(
        event.email,
        event.phone,
        event.password,
        name: event.name,
      );

      authResponse.fold(
        (failure) => emit(AuthErrorState<T>(failure.message)),
        (result) => emit(OTPSentState<T>(result.userId, result.otp)),
      );
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState<T>());
    try {
      final result = await forgotPasswordUseCase.execute(event.identifier);

      result.fold((failure) => emit(AuthErrorState<T>(failure.message)), (
        success,
      ) {
        if (success.smsSent ?? false) {
          emit(PasswordResetSentState<T>(otp: success.otp!, userId: success.userId!));
        } else {
          emit(
            AuthErrorState<T>("Failed to send reset code. Please try again."),
          );
        }
      });
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState<T>());
    try {
      await changePasswordUseCase.execute(
        event.currentPassword,
        event.newPassword,
        event.confirmPassword,
      );
      emit(PasswordChangedState<T>());
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (socialLoginUseCase == null) {
      emit(AuthErrorState<T>('Social login is not enabled'));
      return;
    }

    emit(AuthLoadingState<T>());
    try {
      final authResponse = await socialLoginUseCase!.execute(
        event.provider,
        event.token,
        userData: event.userData,
      );
      authResponse.fold(
        (failure) => emit(AuthErrorState<T>(failure.message)),
        (result) => emit(AuthenticatedState<T>(result)),
      );
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState<T>());
    try {
      await logoutUseCase.execute();
      emit(UnauthenticatedState<T>());
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onSendOTP(SendOTPEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState<T>());
    try {
      await sendOTPUseCase.execute(event.phoneNo);
      emit(OTPRequestedState<T>());
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(
    VerifyOTPEvent event,
    Emitter<AuthState<T>> emit,
  ) async {
    emit(AuthLoadingState<T>());
    try {
      await verifyOTPUseCase
          .execute(otp: event.otp, userId: event.userId)
          .then(
            (value) => value.fold(
              (failure) => emit(AuthErrorState<T>(failure.message)),
              (result) {
                dev.log('Hello Joy ');
                dev.log(result.toString());
                emit(AuthenticatedState<T>(result));
              },
            ),
          );

      /// TODO: look into reset Token thing
      // emit(OTPVerifiedState(resetToken));
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState<T>());
    try {
      await resetPasswordUseCase.execute(
        event.resetToken,
        event.newPassword,
        event.confirmPassword,
      );
      emit(PasswordResetState<T>());
    } catch (e) {
      emit(AuthErrorState<T>(e.toString()));
    }
  }
}
