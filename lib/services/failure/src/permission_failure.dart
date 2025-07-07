import '../failure.dart';

class PermissionFailure extends Failure {
  final String? permission;
  final bool isPermanentlyDenied; // New: Track permanent denial

  const PermissionFailure({
    required super.message,
    this.permission,
    String? code,
    super.originalError,
    this.isPermanentlyDenied = false,
  }) : super(code: code ?? 'PERMISSION_ERROR');

  factory PermissionFailure.denied(String permission) => PermissionFailure(
    message: 'Permission denied: $permission',
    permission: permission,
    code: 'PERMISSION_DENIED',
  );

  factory PermissionFailure.locationDisabled() => const PermissionFailure(
    message: 'Location services are disabled',
    code: 'LOCATION_DISABLED',
  );

  // New: Permanent denial factory
  factory PermissionFailure.permanentlyDenied(String permission) => PermissionFailure(
    message: 'Permission permanently denied: $permission',
    permission: permission,
    code: 'PERMISSION_PERMANENTLY_DENIED',
    isPermanentlyDenied: true,
  );
}