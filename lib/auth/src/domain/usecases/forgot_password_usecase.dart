// src/domain/usecases/forgot_password_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:pack/auth/custom_auth.dart';

import 'package:pack/services/failure/src/network_failure.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<NetworkFailure, ForgotPasswordResponse<T>>> execute(String email) {
    return repository.forgotPassword(email);
  }
}