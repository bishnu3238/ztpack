import '../failure.dart';

class UnexpectedFailure extends Failure {
  final DateTime timestamp; // New: Track when error occurred

    UnexpectedFailure({
    required super.message,
    String? code,
    super.originalError,
  })  : timestamp = DateTime.now(),
        super(code: code ?? 'UNEXPECTED_ERROR');

  factory UnexpectedFailure.fromException(dynamic exception) => UnexpectedFailure(
    message: 'An unexpected error occurred: ${exception.toString()}',
    originalError: exception,
  );

  // New: Detailed error report
  String getDetailedReport() => '''
    Unexpected Failure:
    - Message: $message
    - Code: $code
    - Timestamp: $timestamp
    - Original Error: $originalError
    ''';
}