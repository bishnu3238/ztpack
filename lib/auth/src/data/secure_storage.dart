// src/data/secure_storage.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/entities/user_entity.dart';

import 'dart:developer' as dev;


/// Abstract class for secure storage
abstract class SecureStorage<T extends UserEntity> {
  /// Store the authentication token
  Future<void> saveToken(String token);

  /// Get the authentication token
  Future<String?> getToken();

  /// Store the user data
  Future<void> saveUser(T user);
  /// Get the user data
  Future<T?> getUser();
  /// Clear all stored data
  Future<void> clearAll();
}

/// Implementation of secure storage using flutter_secure_storage
class SecureStorageImpl<T extends UserEntity> implements SecureStorage<T> {
  final FlutterSecureStorage _storage;
  final String tokenKey;
  final String userKey;

  final T Function(Map<String, dynamic>) userFromJson;

  SecureStorageImpl({
    required this.tokenKey,
    required this.userKey,
    required this.userFromJson,
  }) : _storage = const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  @override
  Future<void> saveUser(T user) async {
    final userJson = jsonEncode(user.toMap());
    await _storage.write(key: userKey, value: userJson);
    // if (user is User) {
    //   final userJson = jsonEncode(user.toJson());
    //   await _storage.write(key: userKey, value: userJson);
    // }
  }

  // @override
  // Future<UserEntity?> getUser() async {
  //   final userJson = await _storage.read(key: userKey);
  //   if (userJson != null) {
  //     final Map<String, dynamic> userData = jsonDecode(userJson);
  //     return User.fromJson(userData);
  //   }
  //   return null;
  // }
  @override
  Future<T?> getUser() async {
    final userJson = await _storage.read(key: userKey);
    if (userJson != null) {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      dev.log("[SECURE STORAGE] GET USER: $userData");
      Map<String, dynamic> userDataMap = {'data':{'user': userData}};
      return userFromJson(userDataMap);
    }
    return null;
  }

  @override
  Future<void> clearAll() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: userKey);
  }
}