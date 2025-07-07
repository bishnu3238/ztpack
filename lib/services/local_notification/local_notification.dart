library;

export 'models/notification_models.dart';
export 'models/notification_settings.dart';
export 'utils/notification_utils.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/notification_models.dart';
import 'models/notification_settings.dart';
import 'utils/notification_utils.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<NotificationResponse> _onNotificationClick = BehaviorSubject<NotificationResponse>();
  Stream<NotificationResponse> get onNotificationClick => _onNotificationClick.stream;

  final Map<int, BehaviorSubject<double>> _progressControllers = {};
  final NotificationSettings _defaultSettings = NotificationSettings();
  final Map<int, NotificationInfo> _activeNotifications = {};
  static const int _maxNotificationId = 2147483647;
  int _lastNotificationId = 0;

  Future<bool> init({
    NotificationSettings? settings,
    Function(NotificationResponse)? onNotificationResponse,
  }) async {
    try {
      tz.initializeTimeZones();
      final initSettings = await buildInitializationSettings(settings);
      final bool result = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _onNotificationClick.add(response);
          if (onNotificationResponse != null) onNotificationResponse(response);
        },
        onDidReceiveBackgroundNotificationResponse: notificationResponseCallback,
      ) ?? false;
      if (settings != null) _defaultSettings.merge(settings);
      if (Platform.isAndroid) await createDefaultChannels(_plugin);
      return result;
    } catch (e, stack) {
      logNotificationError('Initialization error', e, stack);
      return false;
    }
  }

  Future<int> show({
    int? id,
    required String title,
    required String body,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationStyle style = NotificationStyle.basic,
    List<NotificationAction>? actions,
    NotificationSettings? settings,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      final effectiveSettings = _defaultSettings.copy();
      if (settings != null) effectiveSettings.merge(settings);
      final notificationDetails = await buildPlatformNotificationDetails(
        type: type,
        style: style,
        actions: actions,
        settings: effectiveSettings,
      );
      await _plugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      _activeNotifications[notificationId] = NotificationInfo(
        id: notificationId,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
      );
      return notificationId;
    } catch (e, stack) {
      logNotificationError('Show notification error', e, stack);
      return -1;
    }
  }

  Future<int> showOTPNotification({
    int? id,
    required String otp,
    String title = 'Verification Code',
    String? subtitle,
    int expiryMinutes = 10,
    bool useBigTextStyle = true,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      final String body = subtitle != null
          ? '$subtitle\nYour verification code is: $otp\nValid for $expiryMinutes minutes'
          : 'Your verification code is: $otp\nValid for $expiryMinutes minutes';
      final settings = NotificationSettings()
        ..androidSettings = (AndroidSettings()
          ..channelId = 'otp_channel'
          ..priority = Priority.max
          ..importance = Importance.max
          ..enableVibration = true
          ..vibrationPattern = Int64List.fromList([0, 250, 250, 250])
          ..category = AndroidNotificationCategory.message);
      return await show(
        id: notificationId,
        title: title,
        body: body,
        payload: jsonEncode({'type': 'otp', 'code': otp}),
        type: LocalNotificationType.otp,
        style: useBigTextStyle ? NotificationStyle.bigText : NotificationStyle.basic,
        settings: settings,
      );
    } catch (e, stack) {
      logNotificationError('OTP notification error', e, stack);
      return -1;
    }
  }

  Future<int> showProgressNotification({
    int? id,
    required String title,
    required String body,
    double initialProgress = 0.0,
    bool indeterminate = false,
    bool ongoing = true,
    Map<String, dynamic>? extras,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      if (!_progressControllers.containsKey(notificationId)) {
        _progressControllers[notificationId] = BehaviorSubject<double>.seeded(initialProgress);
        _progressControllers[notificationId]!.listen((progress) async {
          double safeProgress = progress.clamp(0.0, 1.0);
          final int progressPercent = (safeProgress * 100).round();
          final String progressText = indeterminate ? 'In progress...' : '$progressPercent%';
          final androidDetails = AndroidNotificationDetails(
            'progress_channel',
            'Progress Notifications',
            channelDescription: 'For progress updates and downloads',
            importance: Importance.low,
            priority: Priority.low,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: 100,
            progress: progressPercent,
            indeterminate: indeterminate,
            ongoing: ongoing,
            autoCancel: !ongoing,
          );
          final iOSDetails = DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
            threadIdentifier: 'progress',
            interruptionLevel: InterruptionLevel.passive,
            categoryIdentifier: 'download_category',
          );
          final notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iOSDetails,
          );
          String updatedBody = safeProgress >= 1.0 ? 'Download complete' : '$body\n$progressText';
          final Map<String, dynamic> payloadData = {
            'type': 'progress',
            'progress': safeProgress,
            'id': notificationId,
          };
          if (extras != null) payloadData.addAll(extras);
          await _plugin.show(
            notificationId,
            title,
            updatedBody,
            notificationDetails,
            payload: jsonEncode(payloadData),
          );
          if (safeProgress >= 1.0) {
            await updateProgress(id: notificationId, progress: 1.0);
            await Future.delayed(const Duration(seconds: 1));
            await cancelNotification(notificationId);
            await show(
              title: '$title - Complete',
              body: 'The process has finished successfully',
              type: LocalNotificationType.success,
              payload: jsonEncode({'type': 'progress_complete', 'id': notificationId}),
            );
            await _progressControllers[notificationId]?.close();
            _progressControllers.remove(notificationId);
          }
        });
      }
      _progressControllers[notificationId]!.add(initialProgress);
      return notificationId;
    } catch (e, stack) {
      logNotificationError('Progress notification error', e, stack);
      return -1;
    }
  }

  Future<bool> updateProgress({required int id, required double progress}) async {
    try {
      if (!_progressControllers.containsKey(id)) return false;
      _progressControllers[id]!.add(progress);
      return true;
    } catch (e) {
      logNotificationError('Update progress error', e);
      return false;
    }
  }

  Future<int> showScheduledNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationStyle style = NotificationStyle.basic,
    RepeatIntervalPack? repeatInterval,
    List<NotificationAction>? actions,
    NotificationSettings? settings,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      final effectiveSettings = _defaultSettings.copy();
      if (settings != null) effectiveSettings.merge(settings);
      final notificationDetails = await buildPlatformNotificationDetails(
        type: type,
        style: style,
        actions: actions,
        settings: effectiveSettings,
      );
      final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledTzDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: repeatInterval != null
            ? getDateTimeComponents(repeatInterval)
            : DateTimeComponents.dayOfWeekAndTime,
      );
      return notificationId;
    } catch (e, stack) {
      logNotificationError('Scheduled notification error', e, stack);
      return -1;
    }
  }

  Future<int> showCustomNotification({
    int? id,
    required String title,
    required String body,
    String? summary,
    String? expandedBody,
    String? largeIcon,
    String? bigPicture,
    List<String>? lines,
    Map<String, String>? buttonActions,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      NotificationStyle style;
      if (bigPicture != null) {
        style = NotificationStyle.bigPicture;
      } else if (expandedBody != null) {
        style = NotificationStyle.bigText;
      } else if (lines != null && lines.isNotEmpty) {
        style = NotificationStyle.inboxView;
      } else {
        style = NotificationStyle.basic;
      }
      List<NotificationAction>? actions;
      if (buttonActions != null && buttonActions.isNotEmpty) {
        actions = buttonActions.entries.map((entry) {
          return NotificationAction(
            id: entry.key,
            title: entry.value,
          );
        }).toList();
      }
      final settings = NotificationSettings()
        ..androidSettings = (AndroidSettings()
          ..largeIcon = largeIcon
          ..bigPicture = bigPicture
          ..expandedBody = expandedBody
          ..lines = lines
          ..summary = summary);
      return await show(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,
        type: type,
        style: style,
        actions: actions,
        settings: settings,
      );
    } catch (e, stack) {
      logNotificationError('Custom notification error', e, stack);
      return -1;
    }
  }

  Future<List<int>> showGroupNotifications({
    required String groupKey,
    required String groupTitle,
    required List<NotificationContent> notifications,
    LocalNotificationType type = LocalNotificationType.info,
    bool setAsGroup = true,
  }) async {
    try {
      final List<int> notificationIds = [];
      if (setAsGroup && notifications.length > 1) {
        final int summaryId = _generateNotificationId();
        final androidDetails = AndroidNotificationDetails(
          type.channelId,
          type.channelName,
          channelDescription: type.channelDescription,
          importance: type.importance,
          priority: type.priority,
          groupKey: groupKey,
          setAsGroupSummary: true,
          styleInformation: InboxStyleInformation(
            notifications.map((n) => n.body).toList(),
            contentTitle: groupTitle,
            summaryText: '${notifications.length} messages',
          ),
        );
        final iOSDetails = DarwinNotificationDetails(
          threadIdentifier: groupKey,
        );
        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );
        await _plugin.show(
          summaryId,
          groupTitle,
          '${notifications.length} new notifications',
          notificationDetails,
        );
        notificationIds.add(summaryId);
      }
      for (final notification in notifications) {
        final int id = notification.id ?? _generateNotificationId();
        final androidDetails = AndroidNotificationDetails(
          type.channelId,
          type.channelName,
          channelDescription: type.channelDescription,
          importance: type.importance,
          priority: type.priority,
          groupKey: groupKey,
          setAsGroupSummary: false,
        );
        final iOSDetails = DarwinNotificationDetails(
          threadIdentifier: groupKey,
        );
        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        );
        await _plugin.show(
          id,
          notification.title,
          notification.body,
          notificationDetails,
          payload: notification.payload,
        );
        notificationIds.add(id);
      }
      return notificationIds;
    } catch (e, stack) {
      logNotificationError('Group notifications error', e, stack);
      return [];
    }
  }

  Future<int> showSilent({
    int? id,
    required String title,
    required String body,
    String? payload,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationSettings? settings,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      final effectiveSettings = _defaultSettings.copy();
      if (settings != null) effectiveSettings.merge(settings);
      effectiveSettings.androidSettings ??= AndroidSettings();
      effectiveSettings.androidSettings!.importance = Importance.low;
      effectiveSettings.androidSettings!.priority = Priority.low;
      effectiveSettings.androidSettings!.enableVibration = false;
      effectiveSettings.iOSSettings ??= IOSSettings();
      effectiveSettings.iOSSettings!.presentSound = false;
      effectiveSettings.iOSSettings!.presentAlert = false;
      final notificationDetails = await buildPlatformNotificationDetails(
        type: type,
        style: NotificationStyle.basic,
        actions: null,
        settings: effectiveSettings,
      );
      await _plugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      _activeNotifications[notificationId] = NotificationInfo(
        id: notificationId,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
      );
      return notificationId;
    } catch (e, stack) {
      logNotificationError('Show silent notification error', e, stack);
      return -1;
    }
  }

  Future<void> clearBadge() async {
    await clearNotificationBadge(_plugin);
  }

  Future<PermissionStatus> getPermissionStatus() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin == null) return PermissionStatus.unknown;
        final bool? enabled = await androidPlugin.areNotificationsEnabled();
        return enabled == true ? PermissionStatus.granted : PermissionStatus.denied;
      } else if (Platform.isIOS) {
        final iOSPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iOSPlugin == null) return PermissionStatus.unknown;
        return PermissionStatus.granted;
      }
      return PermissionStatus.unknown;
    } catch (e, stack) {
      logNotificationError('Permission status error', e, stack);
      return PermissionStatus.unknown;
    }
  }

  List<NotificationInfo> get notificationHistory => List.unmodifiable(_activeNotifications.values);

  String exportNotificationHistory() {
    return jsonEncode(_activeNotifications.values.map((n) => {
      'id': n.id,
      'title': n.title,
      'body': n.body,
      'type': n.type.toString(),
      'timestamp': n.timestamp.toIso8601String(),
    }).toList());
  }

  Future<bool> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      _activeNotifications.remove(id);
      if (_progressControllers.containsKey(id)) {
        await _progressControllers[id]?.close();
        _progressControllers.remove(id);
      }
      return true;
    } catch (e, stack) {
      logNotificationError('Cancel notification error', e, stack);
      return false;
    }
  }

  Future<bool> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      _activeNotifications.clear();
      for (final controller in _progressControllers.values) {
        await controller.close();
      }
      _progressControllers.clear();
      return true;
    } catch (e, stack) {
      logNotificationError('Cancel all notifications error', e, stack);
      return false;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e, stack) {
      logNotificationError('Get pending notifications error', e, stack);
      return [];
    }
  }

  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.getActiveNotifications() ?? [];
      }
      return [];
    } catch (e, stack) {
      logNotificationError('Get active notifications error', e, stack);
      return [];
    }
  }

  Future<void> dispose() async {
    for (final controller in _progressControllers.values) {
      await controller.close();
    }
    _progressControllers.clear();
    await _onNotificationClick.close();
  }

  int _generateNotificationId() {
    _lastNotificationId = (_lastNotificationId + 1) % _maxNotificationId;
    return _lastNotificationId;
  }

  /// Advanced: Snooze a notification by rescheduling it after [minutes]
  Future<bool> snoozeNotification(int id, {int minutes = 5}) async {
    try {
      final info = _activeNotifications[id];
      if (info == null) return false;
      await cancelNotification(id);
      final newTime = DateTime.now().add(Duration(minutes: minutes));
      await showScheduledNotification(
        id: id,
        title: info.title,
        body: info.body,
        scheduledDate: newTime,
        type: info.type,
      );
      return true;
    } catch (e, stack) {
      logNotificationError('Snooze notification error', e, stack);
      return false;
    }
  }

  /// Advanced: Show notification with a custom sound
  Future<int> showWithSound({
    int? id,
    required String title,
    required String body,
    required String soundFileName,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationSettings? settings,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      final effectiveSettings = _defaultSettings.copy();
      effectiveSettings.androidSettings ??= AndroidSettings();
      effectiveSettings.iOSSettings ??= IOSSettings();
      effectiveSettings.androidSettings!.channelId = type.channelId;
      effectiveSettings.iOSSettings!.sound = soundFileName;
      effectiveSettings.androidSettings!.importance = Importance.max;
      effectiveSettings.androidSettings!.priority = Priority.max;
      effectiveSettings.androidSettings!.enableVibration = true;
      effectiveSettings.iOSSettings!.presentSound = true;
      if (settings != null) effectiveSettings.merge(settings);
      final notificationDetails = await buildPlatformNotificationDetails(
        type: type,
        style: NotificationStyle.basic,
        actions: null,
        settings: effectiveSettings,
      );
      await _plugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
      _activeNotifications[notificationId] = NotificationInfo(
        id: notificationId,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
      );
      return notificationId;
    } catch (e, stack) {
      logNotificationError('Show notification with sound error', e, stack);
      return -1;
    }
  }

  /// Advanced: Show notification with image/file attachment (iOS/Android)
  Future<int> showWithAttachment({
    int? id,
    required String title,
    required String body,
    required String filePath,
    LocalNotificationType type = LocalNotificationType.info,
    NotificationSettings? settings,
  }) async {
    try {
      final notificationId = id ?? _generateNotificationId();
      final effectiveSettings = _defaultSettings.copy();
      effectiveSettings.iOSSettings ??= IOSSettings();
      effectiveSettings.iOSSettings!.attachments = [filePath];
      effectiveSettings.androidSettings ??= AndroidSettings();
      effectiveSettings.androidSettings!.bigPicture = filePath;
      if (settings != null) effectiveSettings.merge(settings);
      final notificationDetails = await buildPlatformNotificationDetails(
        type: type,
        style: NotificationStyle.bigPicture,
        actions: null,
        settings: effectiveSettings,
      );
      await _plugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
      _activeNotifications[notificationId] = NotificationInfo(
        id: notificationId,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
      );
      return notificationId;
    } catch (e, stack) {
      logNotificationError('Show notification with attachment error', e, stack);
      return -1;
    }
  }
}