import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

// Custom exception for connectivity errors
class ConnectivityException implements Exception {
  final String message;
  ConnectivityException(this.message);
  @override
  String toString() => 'ConnectivityException: $message';
}

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;

  // Stream for broadcasting status changes
  final StreamController<ConnectivityStatus> _statusController =
  StreamController<ConnectivityStatus>.broadcast();

  // Throttle mechanism
  DateTime _lastCheck = DateTime.now();
  static const Duration _throttleDuration = Duration(seconds: 5);

  // Retry mechanism
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 2);

  ConnectivityService() {
    _initConnectivityListener();
  }

  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isConnected => _currentStatus == ConnectivityStatus.online;

  /// Stream of real connectivity status (online/offline)
  Stream<ConnectivityStatus> get onStatusChanged => _statusController.stream;

  /// Raw connectivity_plus stream (not recommended for most use cases)
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  void _emitStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      // Throttle to prevent too frequent checks
      if (DateTime.now().difference(_lastCheck) < _throttleDuration) {
        return;
      }
      _lastCheck = DateTime.now();

      try {
        final hasInternet = await hasActiveInternet();
        final newStatus = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
        _emitStatus(newStatus);
      } catch (e, stack) {
        dev.log('Connectivity listener error: $e', stackTrace: stack);
        _emitStatus(ConnectivityStatus.offline);
      }
    });

    // Initial check
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    try {
      final hasInternet = await hasActiveInternet();
      final newStatus = hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline;
      _emitStatus(newStatus);
    } catch (e, stack) {
      dev.log('Error during initial connectivity check: $e', stackTrace: stack);
      _emitStatus(ConnectivityStatus.offline);
    }
  }

  Future<bool> isConnectionHas() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result is List<ConnectivityResult>) {
        return result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.mobile);
      } else if (result is ConnectivityResult) {
        return result == ConnectivityResult.wifi || result == ConnectivityResult.mobile;
      }
      return false;
    } catch (e, stack) {
      dev.log('Error checking connectivity $e', stackTrace: stack);
      return false;
    }
  }

  /// Checks for active internet by resolving multiple domains with retries.
  Future<bool> hasActiveInternet() async {
    int attempt = 0;
    while (attempt <= _maxRetries) {
      try {
        if (!await isConnectionHas()) {
          throw ConnectivityException('No network interface available');
        }

        // Try multiple reliable domains, both IPv4 and IPv6
        for (final domain in ['google.com', 'apple.com', 'microsoft.com', 'cloudflare.com']) {
          try {
            final response = await InternetAddress.lookup(domain, type: InternetAddressType.any)
                .timeout(const Duration(seconds: 3));
            if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
              // Optionally, try to open a socket to port 53 (DNS) or 443 (HTTPS)
              try {
                final socket = await Socket.connect(domain, 443, timeout: const Duration(seconds: 2));
                await socket.close();
                return true;
              } catch (_) {
                // Fallback: DNS lookup was enough
                return true;
              }
            }
          } catch (e) {
            dev.log('Domain check failed for $domain: $e');
            continue;
          }
        }
        // If all domains fail
        throw ConnectivityException('All domain checks failed');
      } catch (e, stack) {
        dev.log('Internet check attempt ${attempt + 1} failed: $e', stackTrace: stack);
        if (attempt == _maxRetries) {
          return false;
        }
        await Future.delayed(_retryDelay);
        attempt++;
      }
    }
    return false;
  }

  void dispose() {
    _statusController.close();
  }
}

