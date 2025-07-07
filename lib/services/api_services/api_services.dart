library api_services;

export 'src/api_response/api_responce.dart';
export 'src/auth_service.dart';
export 'src/base_api_client.dart';
export 'src/catch_service.dart';
export 'src/dio_api_client.dart';
export 'src/http_api_client.dart';
export 'src/log_service.dart';
export 'src/request_config.dart';
export 'src/web_socket_service.dart';
export 'package:dio/dio.dart' show FormData;



import 'dart:developer'as dev;
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../connectivity_service/connectivity_service.dart';
import '../failure/src/network_failure.dart';
import 'src/api_response/api_responce.dart';
import 'src/auth_service.dart';
import 'src/catch_service.dart';
import 'src/dio_api_client.dart';
import 'src/log_service.dart';
import 'src/request_config.dart';
import 'src/web_socket_service.dart';

// --------------- Services ---------------

/// Main API service that combines all functionality
class ApiCallService {
  final DioApiClient _dioClient;
  final WebSocketService _webSocketService;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  final AuthService _authService;
  final LogService _logger;
  bool _isInitialized = false;

  ApiCallService({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
    Duration? defaultTimeout,
    LogService? logger,
    CacheService? cacheService,
    ConnectivityService? connectivityService,
    AuthService? authService,
  }) : _logger = logger ?? LogService(),
       _cacheService = cacheService ?? CacheService(logger ?? LogService()),
       _connectivityService =
           connectivityService ?? ConnectivityService(),
       _authService = authService ?? AuthService(logger ?? LogService()),
       _dioClient = DioApiClient(
         logger: logger ?? LogService(),
         cacheService: cacheService ?? CacheService(logger ?? LogService()),
         connectivityService:
             connectivityService ?? ConnectivityService(),
         authService: authService ?? AuthService(logger ?? LogService()),
         baseUrl: baseUrl,
         defaultHeaders: defaultHeaders,
         defaultTimeout: defaultTimeout,
       ),
       _webSocketService = WebSocketService(
         logger ?? LogService(),
         authService ?? AuthService(logger ?? LogService()),
       ) {
    _isInitialized = true;
  }

  /// Initialize the service (optional additional setup)
  Future<void> initialize() async {
    if (!_isInitialized) {
      _logger.info('Initializing ApiService');
      // Add any additional initialization logic here if needed
      _isInitialized = true;
    }
  }

  /// Make an HTTP request
  Future<Either<NetworkFailure, ApiResponse<T>>> request<T>({
    required RequestConfig config,
    T Function(dynamic data)? responseConverter,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    dev.log("REQUEST: $config");
    return _dioClient.request(
      config: config,
      responseConverter: responseConverter,
    );
  }

  /// Connect to WebSocket
  Future<Either<NetworkFailure, bool>> connectWebSocket(
    String url, {
    Map<String, dynamic>? headers,
    bool addAuthToken = false,
    bool enableReconnect = true,
    bool enablePing = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    return _webSocketService.connect(
      url,
      headers: headers,
      addAuthToken: addAuthToken,
      enableReconnect: enableReconnect,
      enablePing: enablePing,
    );
  }

  /// Send WebSocket message
  Either<NetworkFailure, bool> sendWebSocketMessage(dynamic message) {
    return _webSocketService.sendMessage(message);
  }

  /// Get WebSocket messages stream
  Stream<dynamic> get webSocketMessages => _webSocketService.messagesStream;

  /// WebSocket connection state stream
  Stream<WebSocketConnectionState> get webSocketConnectionState =>
      _webSocketService.connectionStateStream;

  /// Check if WebSocket is connected
  bool get isWebSocketConnected => _webSocketService.isConnected;

  /// Check connectivity status
  Future<bool> isConnected() => _connectivityService.isConnectionHas();

  /// Get connectivity changes stream
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivityService.onConnectivityChanged;

  /// Save authentication token
  Future<void> saveToken(String token) => _authService.saveToken(token);

  /// Get authentication token
  Future<String?> getToken() => _authService.getToken();

  /// Clear authentication token
  Future<void> clearToken() => _authService.deleteToken();

  /// Manage cache
  Future<void> setCache(String key, dynamic data, Duration duration) =>
      _cacheService.setCache(key, data, duration);

  Future<dynamic> getCache(String key) => _cacheService.getCache(key);

  Future<void> clearCache([String? key]) => _cacheService.clearCache(key);

  /// Invalidate cache by key pattern (regex)
  Future<void> invalidateCacheByPattern(String pattern) =>
      _cacheService.invalidateByPattern(pattern);

  /// Cache statistics
  int get memoryCacheEntryCount => _cacheService.memoryEntryCount;
  int get secureCacheEntryCount => _cacheService.secureEntryCount;

  /// Cancel specific or all requests
  void cancelRequests([String? requestId]) =>
      _dioClient.cancelRequests(requestId);

  /// Set log level at runtime
  void setLogLevel(Level level) => _logger.setLogLevel(level);

  /// Cleanup resources
  Future<void> dispose() async {
    _logger.info('Disposing ApiService');
    await _dioClient.dispose();
    await _webSocketService.dispose();
    _isInitialized = false;
  }
}

// Example usage:
/*
void main() async {
  // Initialize the API service
  final apiService = ApiService(
    baseUrl: 'https://api.example.com',
    defaultHeaders: {'Accept': 'application/json'},
    defaultTimeout: Duration(seconds: 30),
  );

  // Make a simple GET request
  final config = RequestConfig(
    baseUrl: 'https://api.example.com',
    endpoint: '/users',
    method: RequestMethod.get,
    cachePolicy: CachePolicy.cacheFirst,
    requiresAuth: true,
  );

  final result = await apiService.request<Map<String, dynamic>>(
    config: config,
    responseConverter: (data) => data as Map<String, dynamic>,
  );

  result.fold(
    (failure) => print('Request failed: ${failure.error}'),
    (response) => print('Request succeeded: ${response.data}'),
  );

  // Connect to WebSocket
  final wsResult = await apiService.connectWebSocket(
    'wss://api.example.com/ws',
    addAuthToken: true,
  );

  wsResult.fold(
    (failure) => print('WebSocket failed: ${failure.error}'),
    (_) {
      // Listen to messages
      apiService.webSocketMessages.listen((message) {
        print('Received: $message');
      });

      // Send a message
      apiService.sendWebSocketMessage({'type': 'hello'});
    },
  );


    void uploadFile() async {
      final apiService = ApiService(baseUrl: 'https://api.example.com');

      final file = File('/path/to/your/file.jpg');
      final config = RequestConfig.forFileUpload(
        baseUrl: 'https://api.example.com',
        endpoint: '/upload',
        files: {'file': file},
        fields: {'description': 'My file upload'},
        requiresAuth: true,
        onSendProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );

      final result = await apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) => data as Map<String, dynamic>,
      );

      result.fold(
        (failure) => print('Upload failed: ${failure.error}'),
        (response) => print('Upload succeeded: ${response.data}'),
      );
    }

  // Cleanup
  await apiService.dispose();
}



*/
