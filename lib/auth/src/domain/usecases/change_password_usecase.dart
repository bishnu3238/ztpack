// src/domain/usecases/change_password_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:pack/auth/custom_auth.dart';

import 'package:pack/services/failure/src/network_failure.dart';

import '../repositories/auth_repository.dart';

class ChangePasswordUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<NetworkFailure, ChangePasswordResponse<T>>> execute(String currentPassword, String newPassword, String confirmPassword) {
    return repository.changePassword(currentPassword, newPassword, confirmPassword);
  }
}
