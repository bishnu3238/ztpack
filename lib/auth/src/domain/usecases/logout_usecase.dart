// src/domain/usecases/logout_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:pack/auth/custom_auth.dart';

import 'package:pack/services/failure/src/network_failure.dart';

import '../repositories/auth_repository.dart';

class LogoutUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  LogoutUseCase(this.repository);

  Future<Either<NetworkFailure, bool>> execute() {
    return repository.logout();
  }
}