import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'log_service.dart';

class CacheService {
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _expirations = {};
  final List<String> _lruKeys = [];
  final int _maxMemoryEntries;
  final FlutterSecureStorage _secureStorage;
  final LogService _logger;
  final Duration _cleanupInterval = const Duration(minutes: 5);

  CacheService(this._logger, {FlutterSecureStorage? secureStorage, int maxMemoryEntries = 100})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _maxMemoryEntries = maxMemoryEntries {
    _startCleanup();
  }

  Future<void> setCache<T>(String key, T data, Duration duration) async {
    try {
      // LRU logic
      if (_memoryCache.length >= _maxMemoryEntries) {
        final oldestKey = _lruKeys.isNotEmpty ? _lruKeys.removeAt(0) : null;
        if (oldestKey != null) {
          _memoryCache.remove(oldestKey);
          _expirations.remove(oldestKey);
        }
      }
      _memoryCache[key] = data;
      _expirations[key] = DateTime.now().add(duration);
      _lruKeys.remove(key);
      _lruKeys.add(key);

      final String value;
      if (data is String) {
        value = data;
      } else {
        value = jsonEncode(data);
      }

      await _secureStorage.write(key: 'cache_$key', value: value);
      await _secureStorage.write(
        key: 'cache_${key}_expiry',
        value: _expirations[key]!.millisecondsSinceEpoch.toString(),
      );
      _logger.debug('Cached data for key: $key');
    } catch (e, stack) {
      _logger.error('Error caching data for key: $key', e, stack);
    }
  }

  Future<T?> getCache<T>(String key) async {
    try {
      if (_memoryCache.containsKey(key)) {
        if (_expirations[key]!.isAfter(DateTime.now())) {
          // LRU update
          _lruKeys.remove(key);
          _lruKeys.add(key);
          _logger.debug('Retrieved from memory cache: $key');
          return _memoryCache[key] as T;
        } else {
          _memoryCache.remove(key);
          _expirations.remove(key);
          _lruKeys.remove(key);
        }
      }

      final data = await _secureStorage.read(key: 'cache_$key');
      if (data == null) return null;

      final expiryStr = await _secureStorage.read(key: 'cache_${key}_expiry');
      if (expiryStr == null) {
        await clearCache(key);
        return null;
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
      if (expiry.isAfter(DateTime.now())) {
        // LRU update
        _lruKeys.remove(key);
        _lruKeys.add(key);
        if (T == String) {
          _memoryCache[key] = data;
          _expirations[key] = expiry;
          return data as T;
        }
        final decoded = jsonDecode(data);
        _memoryCache[key] = decoded;
        _expirations[key] = expiry;
        return decoded as T;
      } else {
        await clearCache(key);
        return null;
      }
    } catch (e, stack) {
      _logger.error('Error retrieving cache for key: $key', e, stack);
      return null;
    }
  }

  Future<void> clearCache([String? key]) async {
    try {
      if (key != null) {
        _memoryCache.remove(key);
        _expirations.remove(key);
        _lruKeys.remove(key);
        await _secureStorage.delete(key: 'cache_$key');
        await _secureStorage.delete(key: 'cache_${key}_expiry');
        _logger.debug('Cleared cache for key: $key');
      } else {
        _memoryCache.clear();
        _expirations.clear();
        _lruKeys.clear();
        final allKeys = await _secureStorage.readAll();
        for (final entry in allKeys.entries) {
          if (entry.key.startsWith('cache_')) {
            await _secureStorage.delete(key: entry.key);
          }
        }
        _logger.debug('Cleared all cache');
      }
    } catch (e, stack) {
      _logger.error('Error clearing cache', e, stack);
    }
  }

  /// Invalidate cache by key pattern (regex)
  Future<void> invalidateByPattern(String pattern) async {
    final regex = RegExp(pattern);
    final keysToRemove = _memoryCache.keys.where((k) => regex.hasMatch(k)).toList();
    for (final key in keysToRemove) {
      await clearCache(key);
    }
  }

  /// Cache statistics
  int get memoryEntryCount => _memoryCache.length;
  int get secureEntryCount => _expirations.length;

  void _startCleanup() {
    Timer.periodic(_cleanupInterval, (_) {
      final now = DateTime.now();
      _expirations.removeWhere((key, expiry) {
        if (expiry.isBefore(now)) {
          _memoryCache.remove(key);
          return true;
        }
        return false;
      });
    });
  }
}