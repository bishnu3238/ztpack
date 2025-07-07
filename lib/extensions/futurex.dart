// Future Extensions
import 'dart:developer' as dev;

extension FutureX<T> on Future<T> {
  /// Logs the result of the future when it completes
  Future<T> logOnComplete([String tag = 'Future']) async {
    final result = await this;
    dev.log('[$tag] Future completed with result: $result');
    return result;
  }

  /// Retries the future on failure
  Future<T> retry(int maxAttempts, {Duration delay = const Duration(seconds: 1)}) async {
    int attempts = 0;
    while (true) {
      try {
        return await this;
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;
        await Future.delayed(delay);
      }
    }
  }

  /// Adds a timeout to the future
  Future<T> withTimeout(Duration timeout, {T Function()? onTimeout}) {
    return this.timeout(timeout, onTimeout: onTimeout);
  }

  /// Maps the result to another type
  Future<R> map<R>(R Function(T) transform) async {
    final result = await this;
    return transform(result);
  }

  /// Executes a callback on success
  Future<T> onSuccess(void Function(T) callback) async {
    final result = await this;
    callback(result);
    return result;
  }

  /// Executes a callback on error
  Future<T> onError(void Function(dynamic) callback) async {
    try {
      return await this;
    } catch (e) {
      callback(e);
      rethrow;
    }
  }
}


