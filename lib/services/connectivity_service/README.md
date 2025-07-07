
# ConnectivityService

A robust, advanced connectivity and internet status checker for Flutter.  
It combines device network status with real internet reachability checks, retries, and error handling.

---

## Features

- Detects device network status (WiFi, Mobile, None)
- Checks for real internet access (not just local network)
- Retries and throttles checks to avoid spamming
- Emits a stream of `ConnectivityStatus` (online/offline)
- Customizable and extensible for advanced use cases

---

## Basic Usage

```dart
import 'package:your_package/services/connectivity_service/connectivity_service.dart';

final connectivityService = ConnectivityService();

void main() async {
  // Check current status
  print('Is connected: ${connectivityService.isConnected}');

  // Listen for status changes
  connectivityService.onStatusChanged.listen((status) {
    print('Connectivity changed: $status');
  });

  // Dispose when done (e.g., in dispose() of a widget)
  // connectivityService.dispose();
}
```

---

## Advanced Usage

### 1. Reactively update UI

```dart
StreamBuilder<ConnectivityStatus>(
  stream: connectivityService.onStatusChanged,
  builder: (context, snapshot) {
    if (snapshot.data == ConnectivityStatus.online) {
      return Text('Online');
    } else {
      return Text('Offline');
    }
  },
);
```

### 2. Manual Connectivity Check

```dart
await connectivityService.checkConnectivity();
print('Current status: ${connectivityService.currentStatus}');
```

### 3. Custom Error Handling

The service logs errors using `dart:developer` and throws a `ConnectivityException` for advanced error handling.

---

## API Reference

- `ConnectivityService()`: Constructor, starts listening for connectivity changes.
- `ConnectivityStatus get currentStatus`: Current status (online/offline).
- `bool get isConnected`: True if online.
- `Stream<ConnectivityStatus> get onStatusChanged`: Emits status changes.
- `Future<void> checkConnectivity()`: Manually trigger a connectivity check.
- `void dispose()`: Close the stream controller when done.

---

## Notes

- The service uses both network interface checks and real internet reachability (DNS + socket).
- For most apps, use `onStatusChanged` to react to connectivity changes.
- For background or singleton use, instantiate once and reuse.

---

## Extending

You can subclass or wrap `ConnectivityService` to:
- Add custom domains for reachability
- Integrate with analytics or logging
- Add platform-specific checks

---

## License

MIT or your project license.
````

</file>