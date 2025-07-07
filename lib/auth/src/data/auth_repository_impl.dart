import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'models/change_password_request.dart';
import 'package:pack/services/failure/failure.dart';
import '../../../services/api_services/api_services.dart';
import '../../../services/failure/src/network_failure.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/models/auth_response.dart';
import 'secure_storage.dart';
import 'models/login_request.dart';
import 'models/otp_request.dart';
import 'models/signup_request.dart';

class AuthRepositoryImpl<T extends UserEntity> implements AuthRepository<T> {
  final String baseUrl;
  final String otpEndpoint;
  final String loginEndpoint;
  final String signupEndpoint;
  final String logoutEndpoint;
  final ApiCallService apiService;
  final String socialLoginEndpoint;
  final String forgotPasswordEndpoint;
  final String resetPasswordEndpoint;
  final String changePasswordEndpoint;
  final SecureStorage<T> secureStorage;
  final T Function(Map<String, dynamic>) userFromJson;

  AuthRepositoryImpl({
    required this.apiService,
    required this.secureStorage,
    required this.userFromJson,
    required this.loginEndpoint,
    required this.signupEndpoint,
    required this.otpEndpoint,
    required this.forgotPasswordEndpoint,
    required this.changePasswordEndpoint,
    required this.socialLoginEndpoint,
    required this.logoutEndpoint,
    required this.baseUrl,
    required this.resetPasswordEndpoint,
  });

  Future<void> _addAuthHeader() async {
    final token = await secureStorage.getToken();
    if (token != null) {
      apiService.saveToken("Bearer $token");
      // apiService.dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// ------------------------ login start  ------------------------------------

  @override
  Future<Either<NetworkFailure, LoginResponse<T>>> login(
    String emailOrUsername,
    String password,
  ) async {
    try {
      final request = LoginRequest(
        emailOrUsername: emailOrUsername,
        password: password,
      );
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: loginEndpoint,
        method: RequestMethod.post,
        body: request.toJson(),
        requiresAuth: false,
        retryEnabled: true,
        maxRetries: 3,
      );
      final response = await apiService.request<LoginResponse<T>>(
        config: config,
        responseConverter: (data) => LoginResponse<T>.convert(data),
      );

      return response.fold((failure) => left(failure), (authResponse) async {
        dev.log("RESPONSE: ${authResponse.data}");
        if (authResponse.data!.user == null) {
          return left(NetworkFailure(message: 'User not found'));
        }
        await secureStorage.saveToken(authResponse.data!.token!);
        await secureStorage.saveUser(authResponse.data!.user!);
        return right(authResponse.data!);
      });
    } on Exception catch (e) {
      dev.log('$e');
      return left(
        NetworkFailure(message: '$e', type: NetworkErrorType.unknown),
      );
    }
  }

  /// ------------------------ login end  --------------------------------------

  /// ------------------------ get user start  ---------------------------------
  @override
  Future<T?> getCurrentUser() async => await secureStorage.getUser();

  /// ------------------------ get user end ------------------------------------

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Either<NetworkFailure, bool>> logout() async {
    try {
      final response = await apiService.request<bool>(
        config: RequestConfig(
          baseUrl: baseUrl,
          endpoint: logoutEndpoint,
          method: RequestMethod.post,
          headers: {
            'Authorization': 'Bearer ${await secureStorage.getToken()}',
          },
        ),
        responseConverter: (_) => true,
      );
      await secureStorage.clearAll();
      return response.fold((l) => left(l), (r) => right(r.data!));
    } catch (e) {
      await secureStorage.clearAll();
      return right(true);
    }
  }

  /// ------------------------ change password start ---------------------------
  @override
  Future<Either<NetworkFailure, ChangePasswordResponse<T>>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    final config = RequestConfig(
      baseUrl: baseUrl,
      endpoint: changePasswordEndpoint,
      body: jsonEncode(request.toJson()),
      method: RequestMethod.post,
    );

    try {
      return await apiService
          .request<ChangePasswordResponse<T>>(
            config: config,
            responseConverter:
                (data) => ChangePasswordResponse<T>.convert(data),
          )
          .then(
            (value) => value.fold(
              (failure) => left(NetworkFailure(message: failure.message)),
              (response) async {
                dev.log("ChangePasswordResponse: ${response.data}");
                if (response.data!.user == null) {
                  return left(
                    NetworkFailure(
                      message: 'User not found',
                      type: NetworkErrorType.unknown,
                    ),
                  );
                }
                await secureStorage.saveToken(response.data!.token);
                await secureStorage.saveUser(response.data!.user!);
                return right(response.data!);
              },
            ),
          );
    } catch (e) {
      LogService().error('$e');
      return left(_handleError(e));
    }
  }

  /// ------------------------ change password end -----------------------------

  @override
  Future<Either<NetworkFailure, ForgotPasswordResponse<T>>> forgotPassword(
    String identifier,
  ) async {
    try {
      // Determine if the identifier is an email or phone number using regex
      bool isEmail = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(identifier);

      Map<String, dynamic> body =
          isEmail ? {'email': identifier} : {'phone': identifier};

      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: forgotPasswordEndpoint,
        method: RequestMethod.post,
        body: jsonEncode(body),
      );

      return await apiService
          .request<ForgotPasswordResponse<T>>(
            config: config,
            responseConverter:
                (data) => ForgotPasswordResponse<T>.convert(data),
          )
          .then(
            (value) => value.fold(
              (failure) => left(NetworkFailure(message: failure.message)),
              (response) => right(response.data!),
            ),
          );
    } catch (e) {
      dev.log('FORGOT PASSWORD ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> sendOTP(String identifier) async {
    try {
      bool isEmail = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(identifier);

      Map<String, dynamic> body =
          isEmail ? {'email': identifier} : {'phone': identifier};

      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: otpEndpoint,
        method: RequestMethod.post,
        body: jsonEncode(body),
      );

      return await apiService
          .request<bool>(
            config: config,
            responseConverter: (data) {
              if (data is Map<String, dynamic> &&
                  data.containsKey('status') &&
                  data['status'] == 'success') {
                return true;
              }
              return false;
            },
          )
          .then(
            (value) => value.fold(
              (failure) => left(NetworkFailure(message: failure.message)),
              (response) => right(response.data ?? false),
            ),
          );
    } catch (e) {
      dev.log('SEND OTP ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<NetworkFailure, bool>> resetPassword(
    String resetToken,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final body = {
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: resetPasswordEndpoint,
        method: RequestMethod.post,
        body: jsonEncode(body),
      );

      return await apiService
          .request<bool>(
            config: config,
            responseConverter: (data) {
              if (data is Map<String, dynamic> &&
                  data.containsKey('status') &&
                  data['status'] == 'success') {
                return true;
              }
              return false;
            },
          )
          .then(
            (value) => value.fold(
              (failure) => left(NetworkFailure(message: failure.message)),
              (response) => right(response.data ?? false),
            ),
          );
    } catch (e) {
      dev.log('RESET PASSWORD ERROR: $e');
      return left(NetworkFailure(message: e.toString()));
    }
  }

  /// ------------------------ Sign up start -----------------------------------
  @override
  Future<Either<NetworkFailure, SignupResponse<T>>> signup(
    String email,
    String phone,
    String password, {
    String? name,
  }) async {
    dev.log("Sign up Function called here ");
    final request = SignupRequest(
      email: email,
      password: password,
      name: name ?? 'User',
      phone: phone,
    );
    final config = RequestConfig(
      baseUrl: baseUrl,
      endpoint: signupEndpoint,
      method: RequestMethod.post,
      body: jsonEncode(request.toJson()),
    );
    try {
      return await apiService
          .request<SignupResponse<T>>(
            config: config,
            responseConverter: (data) {
              dev.log('SIGNUP => $data');
              return SignupResponse<T>.convert(data);
            },
          )
          .then(
            (value) => value.fold(
              (failure) {
                dev.log("CUSTOMER SIGN UP FAILURE : $failure");
                return left(NetworkFailure(message: failure.message));
              },
              (result) async => right(result.data!.copyWith(request: request)),
            ),
          );
    } catch (e) {
      dev.log("CUSTOMER SIGN UP TRY CATCH $e");
      LogService().error('$e');
      _handleError(e);
    }
  }

  /// ------------------------ Sign up end -------------------------------------

  @override
  Future<Either<NetworkFailure, AuthResponse<T>>> socialLogin(
    String provider,
    String token, {
    Map<String, dynamic>? userData,
  }) {
    // TODO: implement socialLogin
    throw UnimplementedError();
  }

  /// ------------------------ verify OTP start --------------------------------
  @override
  Future<Either<NetworkFailure, OtpVerifyResponse<T>>> verifyOTP({
    required String userId,
    required String otp,
  }) async {
    try {
      final request = OtpRequest(otp: otp, userId: userId);

      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: otpEndpoint,
        method: RequestMethod.post,
        body: jsonEncode(request.toJson()),
      );

      return await apiService
          .request<OtpVerifyResponse<T>>(
            config: config,
            responseConverter: (data) => OtpVerifyResponse<T>.convert(data),
          )
          .then(
            (value) => value.fold(
              (failure) => left(NetworkFailure(message: failure.message)),
              (authResponse) async {
                dev.log(authResponse.data!.user.toString());

                // Save auth request
                await secureStorage.saveToken(authResponse.data!.token!);
                await secureStorage.saveUser(authResponse.data!.user!);
                dev.log('message');
                return right(authResponse.data!);
              },
            ),
          );
    } catch (e) {
      dev.log('VERIFY OTP ERROR:  $e');
      _handleError(e);
    }
  }

  /// ------------------------ verify OTP end ----------------------------------

  /// Handle errors from API calls
  Never _handleError(dynamic e) {
    dev.log('ERROR: _handleError =  $e');
    if (e is DioException) {
      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final message =
              e.response!.data['message'] ?? 'An unknown error occurred';
          throw Exception(message);
        }
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception(
            'Connection timeout. Please check your internet connection.',
          );
        case DioExceptionType.badCertificate:
        case DioExceptionType.connectionError:
          throw Exception(
            'Connection error. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          throw Exception('The server returned an unexpected response.');
        case DioExceptionType.cancel:
          throw Exception('The request was cancelled.');
        default:
          throw Exception('Network error. Please try again.');
      }
    }

    throw Exception(e.toString());
  }

  @override
  Future<Either<NetworkFailure, bool>> sendEmail(String email) {
    // TODO: implement sendEmail
    throw UnimplementedError();
  }
}

// // src/data/auth_repository_impl.dart
// import 'dart:convert';
// import 'dart:developer' as dev;
//
// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import 'package:logger/logger.dart';
// import 'package:pack/services/api_services/api_services.dart';
// import '../../../services/failure/src/auth_failure.dart';
// import '../domain/repositories/auth_repository.dart';
// import '../domain/entities/user_entity.dart';
// import 'models/auth_response.dart';
// import 'models/login_request.dart';
// import 'models/otp_request.dart';
// import 'models/signup_request.dart';
// import 'models/forgot_password_request.dart';
// import 'models/change_password_request.dart';
// import 'models/social_login_request.dart';
// import 'secure_storage.dart';
//
// /// Implementation of AuthRepository interface
// class AuthRepositoryImpl implements AuthRepository {
//    final ApiCallService apiCallService;
//   final SecureStorage secureStorage;
//   final String baseUrl;
//   final String loginEndpoint;
//   final String signupEndpoint;
//   final String forgotPasswordEndpoint;
//   final String changePasswordEndpoint;
//   final String socialLoginEndpoint;
//   final String logoutEndpoint;
//   final String otpEndpoint;
//
//   AuthRepositoryImpl({
//      required this.baseUrl,
//     required this.secureStorage,
//     required this.loginEndpoint,
//     required this.signupEndpoint,
//     required this.apiCallService,
//     required this.forgotPasswordEndpoint,
//     required this.changePasswordEndpoint,
//     required this.socialLoginEndpoint,
//     required this.logoutEndpoint,
//     required this.otpEndpoint,
//   });
//
//   /// Add authorization header to requests if token is available
//   Future<void> _addAuthHeader() async {
//     final token = await secureStorage.getToken();
//     if (token != null) {
//       dio.options.headers['Authorization'] = 'Bearer $token';
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, AuthResponse>> login(
//     String emailOrUsername,
//     String password,
//   ) async {
//     try {
//       final request = LoginRequest(
//         emailOrUsername: emailOrUsername,
//         password: password,
//       );
//
//       final response = await apiCallService.request<AuthResponse?>(
//         config: RequestConfig(
//           baseUrl: 'https://eazytechno.com/ead_api/auth/auth.php',
//           endpoint: loginEndpoint,
//           body: jsonEncode(request.toJson()),
//           method: RequestMethod.post,
//         ),
//         responseConverter: (response) {
//           dev.log("INITIAL RESPONSE: $response");
//           return AuthResponse.fromJson(response['data'], AuthType.login);
//         },
//       );
//
//       dev.log('API: $loginEndpoint, REQUEST: $request;');
//
//       return response.fold(
//         (failure) {
//           dev.log('$failure');
//           return left(AuthFailure(message: failure.message));
//         },
//         (result) async {
//           dev.log("RESPONSE: $result");
//           // Save auth data
//           if (result.data != null) {
//             if (result.data!.token != null) {
//               await secureStorage.saveToken(result.data!.token!);
//               await secureStorage.saveUser(result.data!.user!);
//             }
//           }
//           return right(result.data!);
//         },
//       );
//     } catch (e) {
//       dev.log(e.toString());
//       _handleError(e);
//     }
//   }
//
//   @override
//   Future<Either<AuthFailure, AuthResponse>> signup(
//     String email,
//     String phone,
//     String password, {
//     String? name,
//   }) async {
//     try {
//       final data = SignupRequest(
//         email: email,
//         password: password,
//         name: name ?? 'User',
//         phone: phone,
//       );
//       final request = RequestConfig(
//         baseUrl: baseUrl,
//         endpoint: signupEndpoint,
//         method: RequestMethod.post,
//         body: jsonEncode(data.toJson()),
//       );
//
//       return apiCallService
//           .request(
//             config: request,
//             responseConverter: (data) {
//               dev.log("INITIAL RESULT: $data");
//               return AuthResponse.fromJson(data['data'], AuthType.signup);
//             },
//           )
//           .then(
//             (value) => value.fold(
//               (failure) => left(AuthFailure(message: failure.message)),
//               (result) async => right(result.data!),
//             ),
//           );
//     } catch (e) {
//       dev.log('$e');
//       _handleError(e);
//     }
//   }
//
//   @override
//   Future<bool> sendOTP(String email) async {
//     try {
//       final request = ForgotPasswordRequest(email: email);
//       await dio.post('/auth/send-otp', data: request.toJson());
//       return true;
//     } catch (e) {
//       _handleError(e);
//     }
//   }
//
//   // @override
//   // Future<String> verifyOTP(String email, String otp) async {
//   //   try {
//   //     final response = await dio.post(
//   //       '/auth/verify-otp',
//   //       data: {'email': email, 'otp': otp},
//   //     );
//   //     final resetToken = response.data['reset_token'] as String?;
//   //     if (resetToken == null) {
//   //       throw Exception('No reset token received');
//   //     }
//   //     return resetToken;
//   //   } catch (e) {
//   //     _handleError(e);
//   //   }
//   // }
//
//   @override
//   Future<bool> resetPassword(
//     String resetToken,
//     String newPassword,
//     String confirmPassword,
//   ) async {
//     try {
//       await dio.post(
//         '/auth/reset-password',
//         data: {
//           'reset_token': resetToken,
//           'new_password': newPassword,
//           'confirm_password': confirmPassword,
//         },
//       );
//       return true;
//     } catch (e) {
//       _handleError(e);
//     }
//   }
//
//   @override
//   Future<bool> forgotPassword(String email) async {
//     try {
//       final request = ForgotPasswordRequest(email: email);
//
//       await dio.post(forgotPasswordEndpoint, data: request.toJson());
//
//       return true;
//     } catch (e) {
//       _handleError(e);
//     }
//   }
//
//   @override
//   Future<bool> changePassword(
//     String currentPassword,
//     String newPassword,
//     String confirmPassword,
//   ) async {
//     try {
//       await _addAuthHeader();
//
//       final request = ChangePasswordRequest(
//         currentPassword: currentPassword,
//         newPassword: newPassword,
//         confirmPassword: confirmPassword,
//       );
//
//       await dio.post(changePasswordEndpoint, data: request.toJson());
//
//       return true;
//     } catch (e) {
//       _handleError(e);
//     }
//   }
//
//   @override
//   Future<AuthResponse> socialLogin(
//     String provider,
//     String token, {
//     Map<String, dynamic>? userData,
//   }) async {
//     try {
//       final request = SocialLoginRequest(
//         provider: provider,
//         token: token,
//         userData: userData,
//       );
//
//       final response = await dio.post(
//         socialLoginEndpoint,
//         data: request.toJson(),
//       );
//
//       final authResponse = AuthResponse.fromJson(response.data, AuthType.login);
//
//       // Save auth data
//       await secureStorage.saveToken(authResponse.token!);
//       await secureStorage.saveUser(authResponse.user!);
//
//       return authResponse;
//     } catch (e) {
//       _handleError(e);
//     }
//   }
//
//   @override
//   Future<bool> logout() async {
//     try {
//       await _addAuthHeader();
//
//       await dio.post(logoutEndpoint);
//
//       // Clear stored data regardless of API response
//       await secureStorage.clearAll();
//
//       return true;
//     } catch (e) {
//       // Even if API call fails, clear local data
//       await secureStorage.clearAll();
//       return true;
//     }
//   }
//
//   @override
//   Future<UserEntity?> getCurrentUser() async {
//     return await secureStorage.getUser();
//   }
//
//   @override
//   Future<bool> isAuthenticated() async {
//     final token = await secureStorage.getToken();
//     return token != null && token.isNotEmpty;
//   }
//
//   /// Handle errors from API calls
//   Never _handleError(dynamic e) {
//     if (e is DioException) {
//       if (e.response != null) {
//         if (e.response!.data is Map<String, dynamic>) {
//           final message =
//               e.response!.data['message'] ?? 'An unknown error occurred';
//           throw Exception(message);
//         }
//       }
//
//       switch (e.type) {
//         case DioExceptionType.connectionTimeout:
//         case DioExceptionType.sendTimeout:
//         case DioExceptionType.receiveTimeout:
//           throw Exception(
//             'Connection timeout. Please check your internet connection.',
//           );
//         case DioExceptionType.badCertificate:
//         case DioExceptionType.connectionError:
//           throw Exception(
//             'Connection error. Please check your internet connection.',
//           );
//         case DioExceptionType.badResponse:
//           throw Exception('The server returned an unexpected response.');
//         case DioExceptionType.cancel:
//           throw Exception('The request was cancelled.');
//         default:
//           throw Exception('Network error. Please try again.');
//       }
//     }
//
//     throw Exception(e.toString());
//   }
//
//   @override
//   Future<Either<AuthFailure, AuthResponse>> verifyOTP(
//     String otp,
//     String userId,
//   ) async {
//     try {
//       final request = OtpRequest(otp: otp, userId: userId);
//
//       final response = await dio.post(otpEndpoint, data: request.toJson());
//
//       final authResponse = AuthResponse.fromJson(
//         response.data,
//         AuthType.otpVerification,
//       );
//
//       // Save auth data
//       await secureStorage.saveToken(authResponse.token!);
//       await secureStorage.saveUser(authResponse.user!);
//
//       return right(authResponse);
//     } catch (e) {
//       _handleError(e);
//     }
//   }
// }
