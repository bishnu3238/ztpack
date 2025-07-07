
// src/domain/entities/auth_entity.dart
import 'user_entity.dart';

abstract class AuthEntity {
  UserEntity get user;
  String get token;
  String? get refreshToken;
  DateTime? get expiresAt;
}