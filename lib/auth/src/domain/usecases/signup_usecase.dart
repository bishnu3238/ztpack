// src/domain/usecases/signup_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:pack/services/failure/src/network_failure.dart';

import '../../../../services/failure/src/auth_failure.dart';
import '../../data/models/auth_response.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  SignupUseCase(this.repository);

  Future<Either<NetworkFailure, SignupResponse<T>>> execute(
    String email,
    String phone,
    String password, {
    String? name,
  }) {
    return repository.signup(email, phone, password, name: name);
  }
}
