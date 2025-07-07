import 'package:dartz/dartz.dart';
import 'package:pack/auth/custom_auth.dart';

import 'package:pack/auth/src/data/models/auth_response.dart';

import 'package:pack/services/failure/src/auth_failure.dart';
import 'package:pack/services/failure/src/network_failure.dart';

import '../repositories/auth_repository.dart';

class VerifyOTPUseCase<T extends UserEntity> {
  final AuthRepository<T> repository;

  VerifyOTPUseCase(this.repository);

  Future<Either<NetworkFailure, OtpVerifyResponse<T>>> execute({
    required String otp,
    required String userId,
  }) async {
    return await repository.verifyOTP(otp: otp, userId: userId);
  }
}
