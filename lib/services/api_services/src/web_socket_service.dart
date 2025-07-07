import 'dart:async';
import 'dart:convert';
 import 'package:dartz/dartz.dart';
 import 'package:web_socket_channel/web_socket_channel.dart';

 import '../../failure/src/network_failure.dart';
 import 'auth_service.dart';
import 'log_service.dart';

/// WebSocket service
class WebSocketService {
  WebSocketChannel? _channel;
  final LogService _logger;
  final AuthService _authService;
  final StreamController<dynamic> _messagesController =
      StreamController.broadcast();
  final StreamController<WebSocketConnectionState> _stateController =
      StreamController.broadcast();
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _reconnectEnabled = false;
  String? _lastUrl;
  Map<String, dynamic>? _lastHeaders;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 3);
  final Duration _pingInterval = const Duration(seconds: 30);

  WebSocketService(this._logger, this._authService);

  bool get isConnected => _channel != null;
  Stream<dynamic> get messagesStream => _messagesController.stream;
  Stream<WebSocketConnectionState> get connectionStateStream => _stateController.stream;

  Future<Either<NetworkFailure, bool>> connect(
    String url, {
    Map<String, dynamic>? headers,
    bool addAuthToken = false,
    bool enableReconnect = true,
    bool enablePing = true,
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    // Clean up any existing connection
    await disconnect();

    _reconnectEnabled = enableReconnect;
    _lastUrl = url;
    _lastHeaders = headers;
    _reconnectAttempts = 0;

    _stateController.add(WebSocketConnectionState.connecting);

    final result = await _connect(url, headers, addAuthToken, enablePing, onConnect, onDisconnect);
    if (result.isLeft()) {
      _stateController.add(WebSocketConnectionState.disconnected);
    }
    return result;
  }

  Future<Either<NetworkFailure, bool>> _connect(
    String url,
    Map<String, dynamic>? headers,
    bool addAuthToken,
    bool enablePing,
   [ void Function()? onConnect,
    void Function()? onDisconnect,]
  ) async {
    try {
      _logger.info('Connecting to WebSocket: $url');

      Map<String, dynamic> finalHeaders = headers ?? {};

      if (addAuthToken) {
        final authHeaders = await _authService.getAuthHeaders();
        finalHeaders.addAll(authHeaders);
      }

      final protocols = finalHeaders.values.map((v) => v.toString()).toList();

      _channel = WebSocketChannel.connect(Uri.parse(url), protocols: protocols);

      // Setup message handling
      _channel!.stream.listen(
        (message) {
          _messagesController.add(message);
        },
        onError: (error, stackTrace) {
          _logger.error('WebSocket error', error, stackTrace);
          _handleDisconnect(onDisconnect: onDisconnect);
        },
        onDone: () {
          _logger.info('WebSocket connection closed');
          _handleDisconnect(onDisconnect: onDisconnect);
        },
      );

      // Setup ping timer if enabled
      if (enablePing) {
        _setupPingTimer();
      }

      _stateController.add(WebSocketConnectionState.connected);
      if (onConnect != null) onConnect();

      _logger.info('WebSocket connected successfully');
      return right(true);
    } catch (e, stack) {
      _logger.error('Failed to connect to WebSocket', e, stack);
      _handleDisconnect(onDisconnect: onDisconnect);

      _stateController.add(WebSocketConnectionState.disconnected);
      if (onDisconnect != null) onDisconnect();

      return left(
        NetworkFailure(
          message: 'WebSocket connection failed: ${e.toString()}',
          stackTrace: stack,
          type: NetworkErrorType.unknown,
        ),
      );
    }
  }

  void _handleDisconnect({int? code, String? reason, void Function()? onDisconnect}) {
    // Cancel ping timer
    _pingTimer?.cancel();
    _pingTimer = null;

    _stateController.add(WebSocketConnectionState.disconnected);
    if (onDisconnect != null) onDisconnect();

    // Exponential backoff for reconnect
    if (_reconnectEnabled &&
        _lastUrl != null &&
        _reconnectAttempts < _maxReconnectAttempts) {
      final delay = Duration(
        seconds: _reconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1)).clamp(1, 32),
      );
      _reconnectAttempts++;

      _logger.info(
        'Scheduling WebSocket reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${delay.inSeconds}s',
      );

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        _connect(_lastUrl!, _lastHeaders, true, true);
      });
    }
  }

  void _setupPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) => sendPing());
  }

  Future<void> sendPing() async {
    if (_channel != null) {
      try {
        _channel!.sink.add('ping');
        _logger.debug('Sent WebSocket ping');
      } catch (e) {
        _logger.error('Failed to send ping', e);
      }
    }
  }

  Either<NetworkFailure, bool> sendMessage(dynamic message) {
    try {
      if (_channel == null) {
        return left(
          NetworkFailure(
            message: 'WebSocket not connected',
            type: NetworkErrorType.notFound,
          ),
        );
      }

      final String serializedMessage =
          message is String ? message : jsonEncode(message);

      _channel!.sink.add(serializedMessage);
      _logger.debug('Sent WebSocket message: $serializedMessage');

      return right(true);
    } catch (e, stack) {
      _logger.error('Failed to send WebSocket message', e, stack);

      return left(
        NetworkFailure(
          message: 'Failed to send WebSocket message: ${e.toString()}',
          stackTrace: stack,
          type: NetworkErrorType.unknown,
        ),
      );
    }
  }

  Future<void> disconnect({int code = 1000, String reason = 'Client disconnected'}) async {
    _reconnectEnabled = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _pingTimer?.cancel();
    _pingTimer = null;

    if (_channel != null) {
      try {
        _logger.info('Closing WebSocket connection');
        await _channel!.sink.close(code, reason);
        _channel = null;
        _stateController.add(WebSocketConnectionState.disconnected);
      } catch (e) {
        _logger.error('Error closing WebSocket connection', e);
      }
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _messagesController.close();
    await _stateController.close();
    _logger.debug('Disposed WebSocketService');
  }
}

// WebSocket connection state enum
enum WebSocketConnectionState { connecting, connected, disconnected }
