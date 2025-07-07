library;

export 'src/auth_failure.dart';
export 'src/network_failure.dart';
export 'src/permission_failure.dart';
export 'src/validation_failure.dart';
export 'src/unexpected_failure.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../service.dart';
import 'src/auth_failure.dart';

@immutable
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({required this.message, this.code, this.originalError});

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';

  // New: Check if failure is recoverable
  bool get isRecoverable =>
      this is! AuthFailure || !(this as AuthFailure).isCritical;

  // New: Standard JSON representation
  Map<String, dynamic> toJson() => {
    'message': message,
    'code': code,
    'originalError': originalError?.toString(),
  };
}

// Enhanced Either extension
extension EitherX<L, R> on Either<L, R> {
  R getRight() => (this as Right<L, R>).value;
  L getLeft() => (this as Left<L, R>).value;

  Either<L, T> mapRight<T>(T Function(R r) f) =>
      fold((l) => Left(l), (r) => Right(f(r)));

  // New: Handle failure with fallback
  R getOrElse(R Function(L failure) fallback) => fold(fallback, (r) => r);

  // New: Check if it's a failure
  bool get isFailure => isLeft();
}

// New: Failure extension for better error handling
extension FailureX on Failure {
  bool get isNetworkFailure => this is NetworkFailure;
  bool get isAuthFailure => this is AuthFailure;
  bool get isValidationFailure => this is ValidationFailure;
  bool get isPermissionFailure => this is PermissionFailure;
  bool get isUnexpectedFailure => this is UnexpectedFailure;

  // New: Check if failure can be retried
  bool get canRetry =>
      this is NetworkFailure && (this as NetworkFailure).isRetriable;

  OperationFailure get asOperationFailure {

    return OperationFailure(
      message: message,
      exception: originalError,
     );
  }
}
