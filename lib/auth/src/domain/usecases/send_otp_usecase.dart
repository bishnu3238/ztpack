import 'package:dartz/dartz.dart';

import 'package:pack/services/failure/src/network_failure.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SendOTPUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  SendOTPUseCase(this.repository);

  Future<Either<NetworkFailure, bool>> execute(String email) {
    return repository.sendOTP(email);
  }
}