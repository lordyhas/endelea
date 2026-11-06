import 'package:endelea/features/session/data/session_effects.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Texts of the rest notification, set from the current locale.
class RestAlertTexts {
  const RestAlertTexts({
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });

  final String title;
  final String body;
  final String channelName;
  final String channelDescription;
}

/// Rest-end notification with flutter_local_notifications.
///
/// Uses an exact alarm when the system allows it (Android 12+ asks for the
/// "Alarms & reminders" permission), an inexact one otherwise.
class LocalRestAlerts implements RestAlerts {
  LocalRestAlerts({required this.settings});

  final AppSettings Function() settings;
  final _plugin = FlutterLocalNotificationsPlugin();
  static const _id = 1;

  bool _initialized = false;
  bool _askedPermission = false;
  RestAlertTexts? texts;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Asks for the notification permission once (Android 13+, iOS).
  Future<void> _ensurePermission() async {
    if (_askedPermission) return;
    _askedPermission = true;
    await _android?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
  }

  @override
  Future<void> schedule(DateTime endsAt) async {
    final texts = this.texts;
    if (texts == null) return;
    try {
      await _init();
      await _ensurePermission();
      final prefs = settings();
      final exact = await _android?.canScheduleExactNotifications() ?? true;
      // One channel per sound/vibration combination: Android freezes a
      // channel's settings once created.
      final channel =
          'rest_end_${prefs.restSound ? 's' : 'n'}${prefs.restVibration ? 'v' : 'n'}';
      await _plugin.zonedSchedule(
        id: _id,
        title: texts.title,
        body: texts.body,
        scheduledDate: tz.TZDateTime.from(endsAt.toUtc(), tz.UTC),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel,
            texts.channelName,
            channelDescription: texts.channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            playSound: prefs.restSound,
            enableVibration: prefs.restVibration,
            visibility: NotificationVisibility.public,
            timeoutAfter: 60000,
          ),
          iOS: DarwinNotificationDetails(
            presentSound: prefs.restSound,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
      );
    } on Object {
      // A missing notification must never break the session.
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _init();
      await _plugin.cancel(id: _id);
    } on Object {
      // Same as above.
    }
  }
}

/// Haptics through the platform (PLAN.md §6.5).
class PlatformSessionHaptics implements SessionHaptics {
  PlatformSessionHaptics({required this.settings});

  final AppSettings Function() settings;

  @override
  Future<void> setCompleted() => HapticFeedback.mediumImpact();

  @override
  Future<void> restEnded() async {
    if (!settings().restVibration) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await HapticFeedback.heavyImpact();
  }
}
