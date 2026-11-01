import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/_core.dart';
import '../../../config/injection_container.dart';

class NotificationManager {
  static bool _enabled = true;

  static Future<void> setEnabled(bool enabled) async {
    if (await getIt<DataStorage>().write(DataStorageKeys.remindersEnabled, enabled) != true) {
      throw StateError('Unable to save notification preference.');
    }
    _enabled = enabled;
    if (!enabled) await _notificationsPlugin.cancelAll();
  }

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int _trialEndingReminderNotificationId = 10001;

  static Future<void> init({required bool enabled}) async {
    _enabled = false;
    try {
      if (!enabled) {
        await _notificationsPlugin.cancelAll();
        return;
      }
      final remindersEnabled =
          await getIt<DataStorage>().read(DataStorageKeys.remindersEnabled) != false;
      tz.initializeTimeZones();
      try {
        final timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
      } catch (e) {
        AppLogger.logError('Failed to set local timezone for notifications: $e');
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      final initialized = await _notificationsPlugin.initialize(settings: initializationSettings);
      _enabled = initialized == true && remindersEnabled;
      AppLogger.logInfo('NotificationManager initialized: $initialized');
    } catch (e) {
      AppLogger.logError('NotificationManager init failed: $e');
    }
  }

  static Future<bool> requestPermission() async {
    // Android
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      AppLogger.logInfo('Notification permission granted: $granted');
      return granted ?? false;
    }

    // iOS
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLogger.logInfo('Notification permission granted: $granted');
      return granted ?? false;
    }

    return false;
  }

  static Future<void> showNotification({required String title, required String body}) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for testing notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      await _notificationsPlugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
      AppLogger.logInfo('Notification shown: $title');
    } catch (e) {
      AppLogger.logError('Failed to show notification: $e');
    }
  }

  static Future<bool> ensurePermission() async {
    return await requestPermission();
  }

  static Future<void> scheduleTrialEndingReminder({required DateTime reminderAt}) async {
    if (!_enabled) return;
    try {
      final scheduledDate = tz.TZDateTime.from(reminderAt, tz.local);
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        AppLogger.logInfo('Trial reminder schedule skipped: date is in the past');
        return;
      }

      const androidNotificationDetails = AndroidNotificationDetails(
        'trial_reminder_channel',
        'Trial Reminders',
        channelDescription: 'Reminder before free trial ends',
        importance: Importance.max,
        priority: Priority.high,
      );

      const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: _trialEndingReminderNotificationId,
        title: 'Your trial ends tomorrow',
        body: 'Cancel anytime before billing starts.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      AppLogger.logInfo('Trial reminder scheduled for: $scheduledDate');
    } catch (e) {
      AppLogger.logError('Failed to schedule trial reminder: $e');
    }
  }

  static Future<void> cancelTrialEndingReminder() async {
    try {
      await _notificationsPlugin.cancel(id: _trialEndingReminderNotificationId);
      AppLogger.logInfo('Trial reminder cancelled');
    } catch (e) {
      AppLogger.logError('Failed to cancel trial reminder: $e');
    }
  }
}
