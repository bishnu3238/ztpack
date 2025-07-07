import '../failure.dart';

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  final int errorCount; // New: Track number of validation errors

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
    String? code,
    super.originalError,
  })  : errorCount = fieldErrors?.length ?? 0,
        super(code: code ?? 'VALIDATION_ERROR');

  factory ValidationFailure.invalidInput(Map<String, String> fieldErrors) =>
      ValidationFailure(
        message: 'Invalid input data (${fieldErrors.length} errors)',
        fieldErrors: fieldErrors,
        code: 'INVALID_INPUT',
      );

  factory ValidationFailure.requiredField(String fieldName) => ValidationFailure(
    message: '$fieldName is required',
    fieldErrors: {fieldName: 'This field is required'},
    code: 'REQUIRED_FIELD',
  );

  // New: Check if a specific field has an error
  bool hasError(String fieldName) => fieldErrors?.containsKey(fieldName) ?? false;

  // New: Get error message for a specific field
  String? getFieldError(String fieldName) => fieldErrors?[fieldName];
}