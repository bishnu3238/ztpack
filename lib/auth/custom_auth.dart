// custom_auth.dart - Main package file exposing public API
library;

import 'dart:developer' as dev;
import 'package:get_it/get_it.dart';
import 'package:pack/services/service.dart';
import 'src/data/auth_repository_impl.dart';
import 'src/data/secure_storage.dart';
import 'src/domain/entities/user_entity.dart';
import 'src/domain/repositories/auth_repository.dart';
import 'src/domain/usecases/change_password_usecase.dart';
import 'src/domain/usecases/forgot_password_usecase.dart';
import 'src/domain/usecases/login_usecase.dart';
import 'src/domain/usecases/logout_usecase.dart';
import 'src/domain/usecases/reset_password_usecase.dart';
import 'src/domain/usecases/send_otp_usecase.dart';
import 'src/domain/usecases/signup_usecase.dart';
import 'src/domain/usecases/social_login_usecase.dart';
import 'src/domain/usecases/verify_otp_usecase.dart';
import 'src/presentation/blocs/auth_bloc.dart';

// Public exports
export 'src/data/models/auth_response.dart';
export 'src/data/models/user.dart';
export 'src/domain/entities/auth_entity.dart';
export 'src/domain/entities/user_entity.dart';
export 'src/presentation/blocs/auth_bloc.dart';
export 'src/presentation/screens/change_password_screen.dart';
export 'src/presentation/screens/forgot_password_screen.dart';
export 'src/presentation/screens/forget_password_otp_screen.dart';
export 'src/presentation/screens/login_screen.dart';
export 'src/presentation/screens/signup_screen.dart';
export 'src/presentation/screens/otp_screen.dart';
export 'src/presentation/widgets/auth_button.dart';
export 'src/presentation/widgets/auth_text_field.dart';
export 'src/presentation/widgets/social_login_button.dart';
export 'src/presentation/providers/auth_provider.dart';

/// GetIt instance for dependency injection
final GetIt getIt = GetIt.instance;
typedef UserConvert<T> = T Function(Map<String, dynamic>);

/// CustomAuth class for initializing the authentication package
class CustomAuth {
  /// Initialize the authentication package with configuration options
  ///
  /// [baseUrl] - The base URL for the authentication API
  /// [loginEndpoint] - The endpoint for login requests (default: '/auth/login')
  /// [signupEndpoint] - The endpoint for signup requests (default: '/auth/signup')
  /// [forgotPasswordEndpoint] - The endpoint for forgot password requests (default: '/auth/forgot-password')
  /// [changePasswordEndpoint] - The endpoint for change password requests (default: '/auth/change-password')
  /// [socialLoginEndpoint] - The endpoint for social login requests (default: '/auth/social-login')
  /// [logoutEndpoint] - The endpoint for logout requests (default: '/auth/logout')
  /// [tokenKey] - The key to use for storing the authentication token (default: 'auth_token')
  /// [userKey] - The key to use for storing user data (default: 'user_data')
  /// [enableSocialLogin] - Enable social login features (default: false)
  ///
  static Future<void> init<T extends UserEntity>({
    required String baseUrl,
    required UserConvert<T> userFromJson, // Function to convert JSON to T
    String loginEndpoint = '/auth/login',
    String signupEndpoint = '/auth/signup',
    String otpEndpoint = '/auth/otp-verify',
    String forgotPasswordEndpoint = '/auth/forgot-password',
    String resetPasswordEndpoint = '/auth/reset-password',
    String changePasswordEndpoint = '/auth/change-password',
    String socialLoginEndpoint = '/auth/social-login',
    String logoutEndpoint = '/auth/logout',
    String tokenKey = 'auth_token',
    String userKey = 'user_data',
    bool enableSocialLogin = false,
    Map<String, String>? defaultHeaders,
    Duration? defaultTimeout,
    LogService? logService,
  }) async {
    final apiCallService = ApiCallService(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders ?? {'Content-Type': 'application/json'},
      defaultTimeout: defaultTimeout ?? const Duration(seconds: 30),
      logger: logService ?? LogService(enableLogging: true),
    );

    final secureStorage = SecureStorageImpl<T>(
      tokenKey: tokenKey,
      userKey: userKey,
      userFromJson: userFromJson,
    );

    getIt.registerLazySingleton<UserConvert<T>>(() => userFromJson);

    getIt.registerLazySingleton<SecureStorage<T>>(() => secureStorage);

    // Register repositories
    getIt.registerLazySingleton<AuthRepository<T>>(
      () => AuthRepositoryImpl<T>(
        baseUrl: baseUrl,
        secureStorage: getIt<SecureStorage<T>>(),
        apiService: apiCallService,
        loginEndpoint: loginEndpoint,
        signupEndpoint: signupEndpoint,
        forgotPasswordEndpoint: forgotPasswordEndpoint,
        changePasswordEndpoint: changePasswordEndpoint,
        socialLoginEndpoint: socialLoginEndpoint,
        resetPasswordEndpoint: resetPasswordEndpoint,
        logoutEndpoint: logoutEndpoint,
        otpEndpoint: otpEndpoint,
        userFromJson: userFromJson,
      ),
    );

    // Register use cases
    getIt.registerLazySingleton<LoginUseCase<T>>(
      () => LoginUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<SignupUseCase<T>>(
      () => SignupUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<ForgotPasswordUseCase<T>>(
      () => ForgotPasswordUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<ChangePasswordUseCase<T>>(
      () => ChangePasswordUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<LogoutUseCase<T>>(
      () => LogoutUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<SendOTPUseCase<T>>(
      () => SendOTPUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<VerifyOTPUseCase<T>>(
      () => VerifyOTPUseCase<T>(getIt<AuthRepository<T>>()),
    );
    getIt.registerLazySingleton<ResetPasswordUseCase<T>>(
      () => ResetPasswordUseCase<T>(getIt<AuthRepository<T>>()),
    );

    // Register social login use case if enabled
    if (enableSocialLogin) {
      getIt.registerLazySingleton<SocialLoginUseCase<T>>(
        () => SocialLoginUseCase<T>(getIt<AuthRepository<T>>()),
      );
    }

    getIt.registerLazySingleton<AuthBloc<T>>(
      () => AuthBloc<T>(
        loginUseCase: getIt<LoginUseCase<T>>(),
        signupUseCase: getIt<SignupUseCase<T>>(),
        forgotPasswordUseCase: getIt<ForgotPasswordUseCase<T>>(),
        changePasswordUseCase: getIt<ChangePasswordUseCase<T>>(),
        logoutUseCase: getIt<LogoutUseCase<T>>(),
        sendOTPUseCase: getIt<SendOTPUseCase<T>>(),
        verifyOTPUseCase: getIt<VerifyOTPUseCase<T>>(),
        resetPasswordUseCase: getIt<ResetPasswordUseCase<T>>(),
        socialLoginUseCase:
            enableSocialLogin ? getIt<SocialLoginUseCase<T>>() : null,
      ),
    );
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated<T extends UserEntity>() async {
    try {
      final storage = getIt<SecureStorage<T>>();
      final token = await storage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get the current authenticated user
  static Future<T?> getCurrentUser<T extends UserEntity>() async {
    try {
      final storage = getIt<SecureStorage<T>>();
      final user = await storage.getUser();
      dev.log('[CUSTOM AUTH] Current User :=> $user');
       return user;
    } catch (e) {
      getIt<LogService>().error('Failed to get current user', e);
      return null;
    }
  }

  /// Logout the current user
  static Future<bool> logout<T extends UserEntity>() async {
    try {
      final logoutUseCase = getIt<LogoutUseCase<T>>();
      return await logoutUseCase.execute().then(
        (value) => value.fold((failure) => false, (result) => result),
      );
    } catch (e) {
      // Silent logout in case of error
      final storage = getIt<SecureStorage<T>>();
      await storage.clearAll();
      return true;
    }
  }

  static Future<void> dispose() async {
    /// TODO : we have to make sure [ApiCallService] should be dispose
    // apiCallService.dispose();
    getIt.reset();
    getIt<LogService>().info('CustomAuth disposed');
  }
}
