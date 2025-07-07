# api_services

A robust, modular API and WebSocket service package for Flutter/Dart.  
Provides HTTP (Dio & http), WebSocket, secure/in-memory caching, authentication, logging, connectivity, and advanced request features.

---

## Why use `api_services`?

- **Consistency:** Unified API for HTTP, WebSocket, caching, and authentication.
- **Productivity:** Handles common patterns (caching, retries, progress, cancellation) so you focus on business logic.
- **Reliability:** Built-in error handling, logging, and connectivity checks.
- **Security:** Secure storage for tokens and cache.
- **Flexibility:** Highly configurable for simple to advanced use cases.

---

## Features & Benefits

- **HTTP client abstraction:** Switch between Dio and http with the same interface.
- **WebSocket client:** Auto-reconnect, ping/pong, connection state stream.
- **Caching:** In-memory (fast) and secure (persistent) with LRU and expiry.
- **Authentication:** Token storage, expiry, and auto-injection in requests.
- **Request cancellation & retry:** Cancel by ID, auto-retry with exponential backoff.
- **Logging:** Customizable, runtime log level, error/exception tracking.
- **Connectivity:** Check and listen for network changes.
- **Advanced requests:** File upload, progress, custom response decoding, cache invalidation by pattern.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  api_services:
    path: ./pack # or your package location
  dio: ^5.0.0
  http: ^1.0.0
  dartz: ^0.10.1
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^5.0.0
  logger: ^2.0.0
```

---

## Getting Started

### 1. Import the package

```dart
import 'package:api_services/api_services.dart';
```

### 2. Initialize the Service

```dart
final apiService = ApiCallService(
  baseUrl: 'https://api.example.com',
  defaultHeaders: {'Accept': 'application/json'},
  defaultTimeout: Duration(seconds: 30),
);
```

**Why?**  
Centralizing your API logic in one service makes your codebase easier to maintain, test, and extend.

---

## Basic Usage

### Simple GET Request

**Why?**  
For most REST APIs, you need to fetch data with GET. This example shows how to do it safely and type-safely.

```dart
final config = RequestConfig(
  baseUrl: 'https://api.example.com',
  endpoint: '/users',
  method: RequestMethod.get,
);

final result = await apiService.request<Map<String, dynamic>>(
  config: config,
  responseConverter: (data) => data as Map<String, dynamic>,
);

result.fold(
  (failure) => print('Request failed: ${failure.message}'),
  (response) => print('Request succeeded: ${response.data}'),
);
```

**Benefit:**  
- Handles errors, timeouts, and connectivity for you.
- You get a strongly-typed response or a detailed failure.

---

## Medium Usage

### Authenticated Request with Caching

**Why?**  
Most APIs require authentication and benefit from caching to reduce network calls and improve speed.

```dart
// Save token (e.g., after login)
await apiService.saveToken('your_jwt_token');

// Make a GET request with cache-first policy and authentication
final config = RequestConfig(
  baseUrl: 'https://api.example.com',
  endpoint: '/profile',
  method: RequestMethod.get,
  requiresAuth: true,
  cachePolicy: CachePolicy.cacheFirst,
);

final result = await apiService.request<Map<String, dynamic>>(
  config: config,
  responseConverter: (data) => data as Map<String, dynamic>,
);

if (result.isRight()) {
  print('Profile: ${result.getOrElse(() => null)?.data}');
}
```

**Benefit:**  
- Token is automatically injected into headers.
- Data is loaded from cache if available, falling back to network if not.
- Reduces latency and API usage.

---

### File Upload

**Why?**  
Uploading files (images, docs) is common in apps. This API makes it easy and tracks progress.

```dart
final file = File('/path/to/file.jpg');
final uploadConfig = RequestConfig.forFileUpload(
  baseUrl: 'https://api.example.com',
  endpoint: '/upload',
  files: {'file': file},
  fields: {'description': 'My file upload'},
  requiresAuth: true,
  onSendProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
  },
);

final uploadResult = await apiService.request<Map<String, dynamic>>(
  config: uploadConfig,
  responseConverter: (data) => data as Map<String, dynamic>,
);
```

**Benefit:**  
- Handles multipart/form-data, progress, and authentication.
- No need to manually build FormData or track upload state.

---

## Advanced Usage

### WebSocket with State Handling

**Why?**  
For real-time features (chat, notifications), you need reliable WebSocket connections.

```dart
final wsResult = await apiService.connectWebSocket(
  'wss://api.example.com/ws',
  addAuthToken: true,
);

wsResult.fold(
  (failure) => print('WebSocket failed: ${failure.message}'),
  (_) {
    // Listen to connection state
    apiService.webSocketConnectionState.listen((state) {
      print('WebSocket state: $state');
    });

    // Listen to messages
    apiService.webSocketMessages.listen((message) {
      print('Received: $message');
    });

    // Send a message
    apiService.sendWebSocketMessage({'type': 'hello'});
  },
);
```

**Benefit:**  
- Handles reconnect, ping/pong, and connection state for you.
- Streams messages and state changes for reactive UI.

---

### Advanced Request Configuration

**Why?**  
For complex APIs, you may need retries, custom decoders, request IDs, or fine-tuned caching.

```dart
final config = RequestConfig(
  baseUrl: 'https://api.example.com',
  endpoint: '/data',
  method: RequestMethod.get,
  queryParameters: {'page': 1},
  requiresAuth: true,
  cachePolicy: CachePolicy.cacheFirst,
  retryEnabled: true,
  maxRetries: 5,
  retryDelay: Duration(seconds: 2),
  requestId: 'unique-request-id',
  customResponseDecoder: (data) => MyModel.fromJson(data),
);

final result = await apiService.request<MyModel>(
  config: config,
);
```

**Benefit:**  
- Retries failed requests with exponential backoff.
- Custom decoders for advanced response mapping.
- Track/cancel requests by ID.

---

## Cache Management

**Why?**  
Caching improves performance and reduces network usage. You can control cache at a granular level.

```dart
// Set cache manually
await apiService.setCache('my_key', {'foo': 'bar'}, Duration(minutes: 10));

// Get cache
final cached = await apiService.getCache('my_key');

// Clear specific cache
await apiService.clearCache('my_key');

// Invalidate cache by pattern (regex)
await apiService.invalidateCacheByPattern(r'^GET_https://api\.example\.com/users');
```

**Benefit:**  
- Fine-grained control over what is cached and for how long.
- Invalidate groups of cache entries with regex patterns.

---

## Logging

**Why?**  
Debugging and monitoring are easier with structured logs.

```dart
// Change log level at runtime
import 'package:logger/logger.dart';
apiService.setLogLevel(Level.warning);
```

**Benefit:**  
- Reduce log noise in production, increase detail in development.
- All network, cache, and error events are logged.

---

## Connectivity

**Why?**  
Apps should gracefully handle network changes.

```dart
final isConnected = await apiService.isConnected();

apiService.onConnectivityChanged.listen((results) {
  print('Connectivity changed: $results');
});
```

**Benefit:**  
- Prevents unnecessary network calls when offline.
- React to connectivity changes in your UI.

---

## Best Practices

- **Type Safety:** Always use `responseConverter` or `customResponseDecoder` for parsing responses.
- **Caching:** Use `cachePolicy` to balance speed and freshness.
- **Request Tracking:** Use `requestId` for tracking/cancelling requests.
- **Resource Management:** Call `await apiService.dispose();` when done to free resources.
- **Token Expiry:** Use `isTokenValid()` before making authenticated requests.

---

## API Reference

See the source code for full API details and advanced configuration.

---

## License

MIT

