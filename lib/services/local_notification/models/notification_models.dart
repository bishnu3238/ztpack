import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';

enum LocalNotificationType {
  info,
  success,
  warning,
  error,
  otp,
  urgent,
  critical;

  String get channelId {
    switch (this) {
      case LocalNotificationType.info:
        return 'general_channel';
      case LocalNotificationType.success:
        return 'general_channel';
      case LocalNotificationType.warning:
        return 'general_channel';
      case LocalNotificationType.error:
        return 'urgent_channel';
      case LocalNotificationType.otp:
        return 'otp_channel';
      case LocalNotificationType.urgent:
        return 'urgent_channel';
      case LocalNotificationType.critical:
        return 'urgent_channel';
    }
  }

  String get channelName {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
      case LocalNotificationType.warning:
        return 'General Notifications';
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
        return 'Urgent Notifications';
      case LocalNotificationType.otp:
        return 'OTP Notifications';
    }
  }

  String get channelDescription {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
      case LocalNotificationType.warning:
        return 'For general app notifications';
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
        return 'For high priority notifications';
      case LocalNotificationType.otp:
        return 'For one-time password notifications';
    }
  }

  Importance get importance {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
        return Importance.defaultImportance;
      case LocalNotificationType.warning:
        return Importance.high;
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
      case LocalNotificationType.otp:
        return Importance.max;
    }
  }

  Priority get priority {
    switch (this) {
      case LocalNotificationType.info:
      case LocalNotificationType.success:
        return Priority.defaultPriority;
      case LocalNotificationType.warning:
        return Priority.high;
      case LocalNotificationType.error:
      case LocalNotificationType.urgent:
      case LocalNotificationType.critical:
      case LocalNotificationType.otp:
        return Priority.max;
    }
  }
}

enum NotificationStyle {
  basic,
  bigText,
  bigPicture,
  inboxView,
  mediaStyle,
  messagingStyle,
}

enum RepeatIntervalPack {
  everyMinute,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
}

enum PermissionStatus {
  granted,
  denied,
  unknown,
}

/// Represents a notification action button.
class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final List<NotificationActionInput>? inputs;
  final bool launchesApp;
  final bool cancelNotification;

  NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.inputs,
    this.launchesApp = true,
    this.cancelNotification = true,
  });
}

/// Represents an input field for a notification action.
class NotificationActionInput {
  final String label;
  final List<String>? choices;
  final bool allowFreeFormInput;

  NotificationActionInput({
    required this.label,
    this.choices,
    this.allowFreeFormInput = true,
  });
}

/// Represents a message for messaging style notifications.
class MessageData {
  final String text;
  final DateTime timestamp;
  final Person person;

  MessageData({
    required this.text,
    required this.timestamp,
    required this.person,
  });

  static MessageData from(MessageData data) {
    return MessageData(
      text: data.text,
      timestamp: data.timestamp,
      person: data.person,
    );
  }
}

/// Represents the content of a notification (for grouping).
class NotificationContent {
  final int? id;
  final String title;
  final String body;
  final String? payload;

  NotificationContent({
    this.id,
    required this.title,
    required this.body,
    this.payload,
  });
}

/// Represents a notification instance for history tracking.
class NotificationInfo {
  final int id;
  final String title;
  final String body;
  final LocalNotificationType type;
  final DateTime timestamp;

  NotificationInfo({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
  });
}
