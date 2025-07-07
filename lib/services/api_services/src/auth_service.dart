import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'log_service.dart';

/// Token management service
class AuthService {
  final FlutterSecureStorage _storage;
  final LogService _logger;
  static const String _tokenKey = 'auth_token';
  final String tokenKey;

  AuthService(this._logger, {FlutterSecureStorage? storage, this.tokenKey = _tokenKey})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token, {DateTime? expiry}) async {
    try {
      await _storage.write(key: tokenKey, value: token);
      if (expiry != null) {
        await _storage.write(key: '${tokenKey}_expiry', value: expiry.millisecondsSinceEpoch.toString());
      }
      _logger.debug('Token saved');
    } catch (e, stack) {
      _logger.error('Failed to save token', e, stack);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: tokenKey);
    } catch (e, stack) {
      _logger.error('Failed to retrieve token', e, stack);
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    final expiryStr = await _storage.read(key: '${tokenKey}_expiry');
    if (expiryStr != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
      if (expiry.isBefore(DateTime.now())) {
        await deleteToken();
        return false;
      }
    }
    return token != null;
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: tokenKey);
      await _storage.delete(key: '${tokenKey}_expiry');
      _logger.debug('Token deleted');
    } catch (e, stack) {
      _logger.error('Failed to delete token', e, stack);
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }
}
