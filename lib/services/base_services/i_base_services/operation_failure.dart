import '../../failure/failure.dart';

/// Generic failure class for operations
class OperationFailure extends Failure {
  // final String message;
  final Object? exception;
  final StackTrace? stackTrace;
  final int? statusCode;

  const OperationFailure({
    required super.message,
    this.exception,
    this.stackTrace,
    this.statusCode,
  })  ;

  @override
  String toString() => 'OperationFailure: $message';
}


extension  OperationFailureExtension on OperationFailure {
  bool get isNetworkError => message == 'Network Error';
  bool get isServerError => message == 'Server Error';
  bool get isTimeout => message == 'Timeout';
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;



}

extension OperationFailureListExtension on List<OperationFailure> {
  bool get hasNetworkError => any((e) => e.isNetworkError);
  bool get hasServerError => any((e) => e.isServerError);
  bool get hasTimeout => any((e) => e.isTimeout);
  bool get hasUnauthorized => any((e) => e.isUnauthorized);
  bool get hasForbidden => any((e) => e.isForbidden);
}

extension OperationFailureStringExtension on NetworkFailure {
  OperationFailure get toOperationFailure {
    return OperationFailure(
      message: message,
      exception: originalError,
      stackTrace: stackTrace,
      statusCode: statusCode,
    );
  }



}