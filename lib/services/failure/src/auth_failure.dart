import '../failure.dart';
import 'dart:convert';

/// Authentication state for better context
enum AuthState {
  initial, // Not authenticated yet
  expired, // Session/token expired
  invalid, // Invalid credentials/token
  locked, // Account locked
  unverified, // Email/phone not verified
  unknown, // Unspecified state
}

class AuthFailure extends Failure {
  final bool isCritical; // Indicates severity
  final AuthState state; // Current auth state
  final int? remainingAttempts; // Login attempts left
  final Duration? lockoutDuration; // Time until unlock
  final String? recoveryUrl; // URL for recovery action
  final Map<String, dynamic>? metadata; // Additional context
  final String? _suggestedAction;

  AuthFailure({
    required super.message,
    String? code,
    super.originalError,
    this.isCritical = false,
    this.state = AuthState.unknown,
    this.remainingAttempts,
    String? suggestedAction,
    this.lockoutDuration,
    this.recoveryUrl,
    this.metadata,
  }) : _suggestedAction = suggestedAction,
       super(code: code ?? 'AUTH_ERROR_${state.name.toUpperCase()}');

  // Factory constructors for common auth failures
  factory AuthFailure.invalidCredentials({
    int? remainingAttempts,
  }) => AuthFailure(
    message: 'Invalid username or password',
    isCritical: true,
    state: AuthState.invalid,
    remainingAttempts: remainingAttempts,
    suggestedAction:
        remainingAttempts != null && remainingAttempts > 0
            ? 'Please check your credentials ($remainingAttempts attempts left)'
            : 'Account may be locked. Try resetting your password.',
  );

  factory AuthFailure.userNotFound() => AuthFailure(
    message: 'User account not found',
    state: AuthState.invalid,
    suggestedAction: 'Please register or check your input',
  );

  factory AuthFailure.sessionExpired({String? recoveryUrl}) => AuthFailure(
    message: 'Your session has expired. Please login again',
    state: AuthState.expired,
    recoveryUrl: recoveryUrl,
    suggestedAction: 'Log in again to continue',
  );

  factory AuthFailure.accountLocked(Duration lockoutDuration) => AuthFailure(
    message: 'Account locked due to too many attempts',
    isCritical: true,
    state: AuthState.locked,
    lockoutDuration: lockoutDuration,
    suggestedAction:
        'Wait ${lockoutDuration.inMinutes} minutes or reset your password',
  );

  factory AuthFailure.unverifiedAccount({String? recoveryUrl}) => AuthFailure(
    message: 'Account not verified. Please verify your email/phone',
    state: AuthState.unverified,
    recoveryUrl: recoveryUrl,
    suggestedAction: 'Check your email/phone for verification instructions',
  );

  factory AuthFailure.invalidToken({dynamic tokenData}) => AuthFailure(
    message: 'Authentication token is invalid or malformed',
    isCritical: true,
    state: AuthState.invalid,
    metadata: {'tokenData': tokenData},
    suggestedAction: 'Please log in again to refresh your token',
  );

  // New: Parse from backend response
  factory AuthFailure.fromBackend(Map<String, dynamic> json) {
    final state = _mapStateFromString(json['state'] ?? 'unknown');
    return AuthFailure(
      message: json['message'] ?? 'Authentication failed',
      code: json['code'],
      isCritical: json['isCritical'] ?? false,
      state: state,
      remainingAttempts: json['remainingAttempts'],
      lockoutDuration:
          json['lockoutSeconds'] != null
              ? Duration(seconds: json['lockoutSeconds'])
              : null,
      recoveryUrl: json['recoveryUrl'],
      metadata: json['metadata'],
    );
  }

  // Utility methods
  @override
  bool get isRecoverable => !isCritical && state != AuthState.locked;

  @override
  Map<String, dynamic> toJson() => {
    'message': message,
    'code': code,
    'isCritical': isCritical,
    'state': state.name,
    'remainingAttempts': remainingAttempts,
    'lockoutDuration': lockoutDuration?.inSeconds,
    'recoveryUrl': recoveryUrl,
    'metadata': metadata,
    'suggestedAction': _suggestedAction,
  };

  String get suggestedAction =>
      _suggestedAction ??
      metadata?['suggestedAction'] ??
      'Please try again or contact support';

  static AuthState _mapStateFromString(String state) => switch (state
      .toLowerCase()) {
    'expired' => AuthState.expired,
    'invalid' => AuthState.invalid,
    'locked' => AuthState.locked,
    'unverified' => AuthState.unverified,
    _ => AuthState.unknown,
  };

  @override
  String toString() =>
      'AuthFailure => state: $state, isCritical: $isCritical, '
      'remainingAttempts: $remainingAttempts, message: $message';
}
