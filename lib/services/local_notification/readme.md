# Using LocalNotificationService in Flutter with get_it, dartz, and provider

This guide provides detailed, step-by-step instructions on how to integrate and use the `LocalNotificationService` package in a Flutter project. To enhance the implementation, we will use `get_it` for dependency injection, `dartz` for functional error handling, and `provider` for state management. By the end of this guide, you'll have a fully functional notification system in your Flutter app.

---

## Introduction

The `LocalNotificationService` is a robust utility built on top of the `flutter_local_notifications` package, designed to simplify and enhance local notification management in Flutter. It offers a variety of features to make notifications more interactive and user-friendly.

### Features
- **Notification Types**: Info, Success, Warning, Error, OTP, Urgent, Critical.
- **Notification Styles**: Basic, Big Text, Big Picture, Inbox View, Media, Messaging.
- **Actions**: Interactive buttons within notifications.
- **Progress Tracking**: Show progress for tasks like downloads or uploads.
- **Scheduling**: Schedule notifications with custom intervals.
- **Grouping**: Organize related notifications together.
- **Cross-Platform**: Works seamlessly on Android and iOS.
- **Error Handling**: Built-in support for logging and robustness.

This guide assumes you have a basic Flutter project and will walk you through integrating `LocalNotificationService` with `get_it`, `dartz`, and `provider`.

---

## Prerequisites

Before proceeding, ensure the following:

- A working Flutter project (Flutter SDK installed and configured).
- Basic understanding of Flutter and Dart.
- The following dependencies added to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^19.0.0  # Check for the latest version
  get_it: ^7.2.0  # Dependency injection
  dartz: ^0.10.1  # Functional error handling
  provider: ^6.0.0  # State management
  rxdart: ^0.27.3  # Reactive programming
  timezone: ^0.9.0  # Time zone support for scheduled notifications
 ```
[//]: # (flutter pub add flutter_local_notifications)
[//]: # (flutter pub get)

Setting Up Dependency Injection with get_it
get_it is a lightweight service locator that allows you to manage and access dependencies (like LocalNotificationService) throughout your app.

Steps
1.Create a Service Locator File
2.In your lib directory, create a file named service_locator.dart.
3.Register LocalNotificationService
4.Add the following code to service_locator.dart to register the service as a singleton:
```dart
import 'package:get_it/get_it.dart';
getIt.registerSingleton<LocalNotificationService>(LocalNotificationService());
```
5.Initialize the Service Locator

Error Handling with dartz
dartz introduces functional programming concepts like Either, which is ideal for handling operations that might succeed or fail (e.g., showing a notification).

Steps
Define a Failure Class
Create a simple class to represent notification-related failures:
```dart
class NotificationFailure {
final String message;
NotificationFailure(this.message);
}
```


[//]: # (Wrap Notification Operations)
[//]: # (Create a method that uses Either to handle the result of showing a notification:)
```dart
import 'package:dartz/dartz.dart';
import 'package:your_project/services/local_notification/local_notification.dart';

Future<Either<NotificationFailure, int>> showNotification({
  required String title,
  required String body,
}) async {
  try {
    final service = getIt<LocalNotificationService>();
    final id = await service.show(title: title, body: body);
    if (id == -1) {
      return left(NotificationFailure('Failed to show notification'));
    }
    return right(id);
  } catch (e) {
    return left(NotificationFailure(e.toString()));
  }
}
```
State Management with provider
provider simplifies state management by allowing you to share and react to notification-related state changes across your app.

Steps
Create a Notification Provider
In your lib directory, create a file named notification_provider.dart:
```dart
import 'package:flutter/material.dart';
import 'package:your_project/services/local_notification/local_notification.dart';

class NotificationProvider with ChangeNotifier {
  final LocalNotificationService _notificationService;

  NotificationProvider(this._notificationService) {
    _notificationService.onNotificationClick.listen((response) {
      // Handle notification click (e.g., navigate or update UI)
      notifyListeners();
    });
  }

  Future<int> showNotification(String title, String body) async {
    final id = await _notificationService.show(title: title, body: body);
    notifyListeners(); // Notify UI of changes
    return id;
  }
  
  void handleNotificationClick(String? payload) {
    print('Notification clicked with payload: $payload');
    // Navigate or update state as needed
    notifyListeners();
  }
  Future<void> checkPermissions() async {
    final service = getIt<LocalNotificationService>();
    final status = await service.checkAndRequestPermission();
    if (status != PermissionStatus.granted) {
      // Handle denial (e.g., show a dialog)
      print('Notification permissions denied');
    }
  }
  // Add more methods as needed (e.g., cancel, update progress)
}
```
[//]: # (Register the Provider)
[//]: # (In your main.dart file, wrap your app with ChangeNotifierProvider:)
```dart
void main() {
  setupServiceLocator();
  final service = DependencyInjector.get<LocalNotificationService>();
  await service.init(
    onNotificationResponse: (response) {
      Provider.of<NotificationProvider>(context, listen: false)
          .handleNotificationClick(response.payload);
    },
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(getIt<LocalNotificationService>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```
[//]: # (Using the Notification Provider)
[//]: # (In your widget, you can now use the provider to show notifications:)
```dart

[//]: # (Best Practices
[//]: # (Request Permissions Early: Prompt for permissions at app startup or before notification-related features are used.
[//]: # (Choose Appropriate Types: Use specific notification types (e.g., OTP, Urgent) for clarity and prioritization.
[//]: # (Handle Errors Gracefully: Leverage dartz to manage failures and inform the user when something goes wrong.
[//]: # (Clean Up Resources: Cancel outdated or unnecessary notifications using service.cancel(id).
[//]: # (Test Across Platforms: Verify behavior on both Android and iOS, as notification styles and permissions differ.)