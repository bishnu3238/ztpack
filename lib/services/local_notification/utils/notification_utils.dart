import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_models.dart';
import '../models/notification_settings.dart';

void logNotificationError(String message, dynamic error, [StackTrace? stack]) {
  dev.log('NotificationService Error - $message: $error', stackTrace: stack);
}

/// Build initialization settings for the plugin
Future<InitializationSettings> buildInitializationSettings(NotificationSettings? settings) async {
  final AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
    settings?.androidSettings?.icon ?? '@mipmap/ic_launcher',
  );
  final DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
    requestAlertPermission: settings?.iOSSettings?.requestAlertPermission ?? true,
    requestBadgePermission: settings?.iOSSettings?.requestBadgePermission ?? true,
    requestSoundPermission: settings?.iOSSettings?.requestSoundPermission ?? true,
    // notificationCategories: ... // Add if needed
  );
  return InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  );
}

/// Create default notification channels for Android
Future<void> createDefaultChannels(FlutterLocalNotificationsPlugin plugin) async {
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin == null) return;
  await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
    'general_channel',
    'General Notifications',
    description: 'For general app notifications',
    importance: Importance.high,
  ));
  await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
    'otp_channel',
    'OTP Notifications',
    description: 'For one-time password notifications',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
  ));
  await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
    'progress_channel',
    'Progress Notifications',
    description: 'For progress updates',
    importance: Importance.low,
  ));
  await androidPlugin.createNotificationChannel(AndroidNotificationChannel(
    'urgent_channel',
    'Urgent Notifications',
    description: 'For high priority notifications',
    importance: Importance.max,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 200, 200, 200]),
  ));
}

/// Build platform notification details (Android/iOS)
Future<NotificationDetails> buildPlatformNotificationDetails({
  required LocalNotificationType type,
  required NotificationStyle style,
  List<NotificationAction>? actions,
  required NotificationSettings settings,
}) async {
  // Android
  final android = settings.androidSettings;
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    android?.channelId ?? type.channelId,
    android?.channelName ?? type.channelName,
    channelDescription: android?.channelDescription ?? type.channelDescription,
    importance: android?.importance ?? type.importance,
    priority: android?.priority ?? type.priority,
    icon: android?.icon,
    largeIcon: android?.largeIcon != null ? FilePathAndroidBitmap(android!.largeIcon!) : null,
    color: android?.color,
    enableVibration: android?.enableVibration ?? true,
    vibrationPattern: android?.vibrationPattern,
    enableLights: android?.enableLights ?? false,
    ledColor: android?.ledColor,
    ledOnMs: android?.ledOnMs,
    ledOffMs: android?.ledOffMs,
    ongoing: android?.ongoing ?? false,
    autoCancel: android?.autoCancel ?? true,
    timeoutAfter: android?.timeoutAfter,
    category: android?.category,
    fullScreenIntent: android?.fullScreenIntent ?? false,
    actions: actions?.map((a) => AndroidNotificationAction(
      a.id,
      a.title,
      icon: a.icon != null ? FilePathAndroidBitmap(a.icon!) : null,
      showsUserInterface: a.launchesApp,
      cancelNotification: a.cancelNotification,
    )).toList(),
    styleInformation: await _androidStyleInfo(style, android),
  );

  // iOS
  final ios = settings.iOSSettings;
  DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: ios?.presentAlert ?? true,
    presentBadge: ios?.presentBadge ?? true,
    presentSound: ios?.presentSound ?? true,
    sound: ios?.sound,
    badgeNumber: ios?.badgeNumber,
    attachments: ios?.attachments?.map((p) => DarwinNotificationAttachment(p)).toList(),
    subtitle: ios?.subtitle,
    threadIdentifier: ios?.threadIdentifier ?? type.name,
    categoryIdentifier: ios?.categoryIdentifier,
    interruptionLevel: ios?.interruptionLevel,
  );

  return NotificationDetails(android: androidDetails, iOS: iOSDetails);
}

Future<StyleInformation> _androidStyleInfo(NotificationStyle style, AndroidSettings? settings) async {
  switch (style) {
    case NotificationStyle.basic:
      return const DefaultStyleInformation(true, true);
    case NotificationStyle.bigText:
      return BigTextStyleInformation(
        settings?.expandedBody ?? '',
        contentTitle: settings?.expandedTitle,
        summaryText: settings?.summary,
        htmlFormatBigText: true,
        htmlFormatTitle: true,
      );
    case NotificationStyle.bigPicture:
      if (settings?.bigPicture == null) {
        return const DefaultStyleInformation(true, true);
      }
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(settings!.bigPicture!),
        largeIcon: settings.largeIcon != null ? FilePathAndroidBitmap(settings.largeIcon!) : null,
        contentTitle: settings.expandedTitle,
        summaryText: settings.summary,
        hideExpandedLargeIcon: true,
      );
    case NotificationStyle.inboxView:
      return InboxStyleInformation(
        settings?.lines ?? [],
        contentTitle: settings?.expandedTitle,
        summaryText: settings?.summary,
      );
    case NotificationStyle.mediaStyle:
      return MediaStyleInformation(
        htmlFormatTitle: true,
        htmlFormatContent: true,
      );
    case NotificationStyle.messagingStyle:
      return MessagingStyleInformation(
        const Person(name: 'Me', important: true),
        conversationTitle: settings?.expandedTitle,
        groupConversation: true,
        messages: settings?.messages?.map((m) => Message(
          m.text,
          m.timestamp,
          m.person,
        )).toList() ?? [],
      );
    default:
      return const DefaultStyleInformation(true, true);
  }
}

/// Static callback for background notification responses
@pragma('vm:entry-point')
void notificationResponseCallback(NotificationResponse response) {
  // Implement background notification logic if needed
}

/// Utility: Clear notification badge (iOS only)
Future<void> clearNotificationBadge(FlutterLocalNotificationsPlugin plugin) async {
  // if (Platform.isIOS) {
  //   await plugin
  //       .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
  //       ?.setBadgeNumber(0);
  // }
  // Android badge clearing is not supported by flutter_local_notifications.
}

/// Utility: Get DateTimeComponents for repeat interval
DateTimeComponents? getDateTimeComponents(RepeatIntervalPack? interval) {
  switch (interval) {
    case RepeatIntervalPack.everyMinute:
      return DateTimeComponents.time;
    case RepeatIntervalPack.hourly:
      return DateTimeComponents.time;
    case RepeatIntervalPack.daily:
      return DateTimeComponents.time;
    case RepeatIntervalPack.weekly:
      return DateTimeComponents.dayOfWeekAndTime;
    case RepeatIntervalPack.monthly:
      return DateTimeComponents.dayOfMonthAndTime;
    case RepeatIntervalPack.yearly:
      return DateTimeComponents.dateAndTime;
    default:
      return null;
  }
}
