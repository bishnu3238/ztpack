import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

import '../../../custom_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class AuthProviderModel<T extends UserEntity> extends ChangeNotifier {
  T? _user;
  String? _token;
  bool _isAuthenticated = false;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription? _authSubscription;

  T? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProviderModel() {
    _initialize();
    _subscribeToAuthBloc();
  }

  void _subscribeToAuthBloc() {
    final authBloc = getIt<AuthBloc<T>>();
    _authSubscription = authBloc.stream.listen((state) {
      dev.log('AUTH PROVIDER STATE UPDATE: $state');

      if (state is AuthLoadingState) {
        _isLoading = true;
        notifyListeners();
      } else {
        _isLoading = false;

        if (state is AuthenticatedState<T>) {
          _user = state.authResponse.user;
          _handleToken(state.authResponse);
          _isAuthenticated = true;
          _errorMessage = null;
        } else if (state is UnauthenticatedState<T>) {
          _user = null;
          _isAuthenticated = false;
        } else if (state is AuthErrorState<T>) {
          _errorMessage = state.message;
        }

        notifyListeners();
      }
    });
  }

  Future<void> initialize() => _initialize();

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await CustomAuth.isAuthenticated<T>();
      _user = await CustomAuth.getCurrentUser<T>();
    } catch (e) {
      dev.log('Error initializing auth provider: $e');
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String emailOrUsername, String password) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(
      LoginEvent(emailOrUsername: emailOrUsername, password: password),
    );
  }

  Future<void> signup(
    String email,
    String phone,
    String password, {
    String? name,
  }) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(
      SignupEvent(email: email, phone: phone, password: password, name: name),
    );
  }

  Future<void> sendOTP(String phone) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(SendOTPEvent(phoneNo: phone));
  }

  Future<void> verifyOTP(String otp, String userId) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(VerifyOTPEvent(otp: otp, userId: userId));
  }

  Future<void> forgotPassword(String email) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(ForgotPasswordEvent(identifier: email));
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(
      ChangePasswordEvent(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
  }

  Future<void> socialLogin(
    String provider,
    String token, {
    Map<String, dynamic>? userData,
  }) async {
    _errorMessage = null;
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(
      SocialLoginEvent(provider: provider, token: token, userData: userData),
    );
  }

  Future<bool> logout() async {
    final authBloc = getIt<AuthBloc<T>>();
    authBloc.add(LogoutEvent());

    // We also perform the direct logout to ensure clean state
    var result = await CustomAuth.logout<T>();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _handleToken(AuthResponse<T> authResponse) {
    switch (authResponse) {
      case LoginResponse<T> loginResponse:
        _token = loginResponse.token;
        break;
      case SignupResponse<T> signupResponse:
      case ForgotPasswordResponse<T> forgotPasswordResponse:
        _token = null;
        break;
      case OtpVerifyResponse<T> otpVerifyResponse:
        _token = otpVerifyResponse.token;
        break;
      case ChangePasswordResponse<T> changePasswordResponse:
        _token = changePasswordResponse.token;
        break;
      default:
        _token = null;
        break;
    }
  }
}
