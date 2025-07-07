// src/domain/usecases/social_login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/services/failure/src/network_failure.dart';

import '../../data/models/auth_response.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  SocialLoginUseCase(this.repository);

  Future<Either<NetworkFailure, AuthResponse<T>>> execute(String provider, String token, {Map<String, dynamic>? userData}) {
    return repository.socialLogin(provider, token, userData: userData);
  }
}
