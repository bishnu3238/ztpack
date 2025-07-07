import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'notification_models.dart';

/// NotificationSettings holds platform-specific notification configuration.
class NotificationSettings {
  AndroidSettings? androidSettings;
  IOSSettings? iOSSettings;

  NotificationSettings({
    this.androidSettings,
    this.iOSSettings,
  });

  NotificationSettings copy() {
    return NotificationSettings(
      androidSettings: androidSettings != null ? AndroidSettings.from(androidSettings!) : null,
      iOSSettings: iOSSettings != null ? IOSSettings.from(iOSSettings!) : null,
    );
  }

  void merge(NotificationSettings other) {
    if (other.androidSettings != null) {
      androidSettings ??= AndroidSettings();
      androidSettings!.merge(other.androidSettings!);
    }
    if (other.iOSSettings != null) {
      iOSSettings ??= IOSSettings();
      iOSSettings!.merge(other.iOSSettings!);
    }
  }
}

/// Android-specific notification settings.
class AndroidSettings {
  String? channelId;
  String? channelName;
  String? channelDescription;
  Importance? importance;
  Priority? priority;
  String? icon;
  String? largeIcon;
  Color? color;
  bool? enableVibration;
  Int64List? vibrationPattern;
  bool? enableLights;
  Color? ledColor;
  int? ledOnMs;
  int? ledOffMs;
  bool? ongoing;
  bool? autoCancel;
  int? timeoutAfter;
  AndroidNotificationCategory? category;
  bool? fullScreenIntent;
  String? expandedTitle;
  String? expandedBody;
  String? bigPicture;
  String? summary;
  List<String>? lines;
  List<MessageData>? messages;

  AndroidSettings({
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.importance,
    this.priority,
    this.icon,
    this.largeIcon,
    this.color,
    this.enableVibration,
    this.vibrationPattern,
    this.enableLights,
    this.ledColor,
    this.ledOnMs,
    this.ledOffMs,
    this.ongoing,
    this.autoCancel,
    this.timeoutAfter,
    this.category,
    this.fullScreenIntent,
    this.expandedTitle,
    this.expandedBody,
    this.bigPicture,
    this.summary,
    this.lines,
    this.messages,
  });

  static AndroidSettings from(AndroidSettings settings) {
    return AndroidSettings(
      channelId: settings.channelId,
      channelName: settings.channelName,
      channelDescription: settings.channelDescription,
      importance: settings.importance,
      priority: settings.priority,
      icon: settings.icon,
      largeIcon: settings.largeIcon,
      color: settings.color,
      enableVibration: settings.enableVibration,
      vibrationPattern: settings.vibrationPattern,
      enableLights: settings.enableLights,
      ledColor: settings.ledColor,
      ledOnMs: settings.ledOnMs,
      ledOffMs: settings.ledOffMs,
      ongoing: settings.ongoing,
      autoCancel: settings.autoCancel,
      timeoutAfter: settings.timeoutAfter,
      category: settings.category,
      fullScreenIntent: settings.fullScreenIntent,
      expandedTitle: settings.expandedTitle,
      expandedBody: settings.expandedBody,
      bigPicture: settings.bigPicture,
      summary: settings.summary,
      lines: settings.lines != null ? List<String>.from(settings.lines!) : null,
      messages: settings.messages?.map((m) => MessageData.from(m)).toList(),
    );
  }

  void merge(AndroidSettings other) {
    channelId = other.channelId ?? channelId;
    channelName = other.channelName ?? channelName;
    channelDescription = other.channelDescription ?? channelDescription;
    importance = other.importance ?? importance;
    priority = other.priority ?? priority;
    icon = other.icon ?? icon;
    largeIcon = other.largeIcon ?? largeIcon;
    color = other.color ?? color;
    enableVibration = other.enableVibration ?? enableVibration;
    vibrationPattern = other.vibrationPattern ?? vibrationPattern;
    enableLights = other.enableLights ?? enableLights;
    ledColor = other.ledColor ?? ledColor;
    ledOnMs = other.ledOnMs ?? ledOnMs;
    ledOffMs = other.ledOffMs ?? ledOffMs;
    ongoing = other.ongoing ?? ongoing;
    autoCancel = other.autoCancel ?? autoCancel;
    timeoutAfter = other.timeoutAfter ?? timeoutAfter;
    category = other.category ?? category;
    fullScreenIntent = other.fullScreenIntent ?? fullScreenIntent;
    expandedTitle = other.expandedTitle ?? expandedTitle;
    expandedBody = other.expandedBody ?? expandedBody;
    bigPicture = other.bigPicture ?? bigPicture;
    summary = other.summary ?? summary;
    lines = other.lines ?? lines;
    messages = other.messages ?? messages;
  }
}

/// iOS-specific notification settings.
class IOSSettings {
  bool? requestAlertPermission;
  bool? requestBadgePermission;
  bool? requestSoundPermission;
  bool? presentAlert;
  bool? presentBadge;
  bool? presentSound;
  String? sound;
  int? badgeNumber;
  List<String>? attachments;
  String? subtitle;
  String? threadIdentifier;
  String? categoryIdentifier;
  InterruptionLevel? interruptionLevel;

  IOSSettings({
    this.requestAlertPermission,
    this.requestBadgePermission,
    this.requestSoundPermission,
    this.presentAlert,
    this.presentBadge,
    this.presentSound,
    this.sound,
    this.badgeNumber,
    this.attachments,
    this.subtitle,
    this.threadIdentifier,
    this.categoryIdentifier,
    this.interruptionLevel,
  });

  static IOSSettings from(IOSSettings settings) {
    return IOSSettings(
      requestAlertPermission: settings.requestAlertPermission,
      requestBadgePermission: settings.requestBadgePermission,
      requestSoundPermission: settings.requestSoundPermission,
      presentAlert: settings.presentAlert,
      presentBadge: settings.presentBadge,
      presentSound: settings.presentSound,
      sound: settings.sound,
      badgeNumber: settings.badgeNumber,
      attachments: settings.attachments != null ? List<String>.from(settings.attachments!) : null,
      subtitle: settings.subtitle,
      threadIdentifier: settings.threadIdentifier,
      categoryIdentifier: settings.categoryIdentifier,
      interruptionLevel: settings.interruptionLevel,
    );
  }

  void merge(IOSSettings other) {
    requestAlertPermission = other.requestAlertPermission ?? requestAlertPermission;
    requestBadgePermission = other.requestBadgePermission ?? requestBadgePermission;
    requestSoundPermission = other.requestSoundPermission ?? requestSoundPermission;
    presentAlert = other.presentAlert ?? presentAlert;
    presentBadge = other.presentBadge ?? presentBadge;
    presentSound = other.presentSound ?? presentSound;
    sound = other.sound ?? sound;
    badgeNumber = other.badgeNumber ?? badgeNumber;
    attachments = other.attachments ?? attachments;
    subtitle = other.subtitle ?? subtitle;
    threadIdentifier = other.threadIdentifier ?? threadIdentifier;
    categoryIdentifier = other.categoryIdentifier ?? categoryIdentifier;
    interruptionLevel = other.interruptionLevel ?? interruptionLevel;
  }
}
