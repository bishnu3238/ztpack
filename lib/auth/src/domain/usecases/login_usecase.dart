import 'package:dartz/dartz.dart';

import '../../../../services/failure/src/network_failure.dart';
import '../../data/models/auth_response.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  LoginUseCase(this.repository);

  Future<Either<NetworkFailure, LoginResponse<T>>> execute(
    String emailOrUsername,
    String password,
  ) {
    return repository.login(emailOrUsername, password);
  }
}
