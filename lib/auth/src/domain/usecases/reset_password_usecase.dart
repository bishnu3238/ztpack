import 'package:dartz/dartz.dart';

import 'package:pack/services/failure/src/network_failure.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase <T extends UserEntity> {
  final AuthRepository<T> repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<NetworkFailure, bool>> execute(String resetToken, String newPassword, String confirmPassword) {
    return repository.resetPassword(resetToken, newPassword, confirmPassword);
  }
}