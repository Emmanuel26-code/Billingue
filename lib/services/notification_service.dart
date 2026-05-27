import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Planifie les rappels selon l'objectif
  Future<void> scheduleReminders(String objectif) async {
    // Annule les anciens rappels
    await _notifications.cancelAll();

    final String message = _getMessage(objectif);
    final int minutes = _getMinutes(objectif);

    // Rappel quotidien à 18h
    await _scheduleDailyAt(
      id: 1,
      title: 'Billingue 🌺',
      body: message,
      hour: 18,
      minute: 0,
    );

    // Rappel du matin à 8h
    await _scheduleDailyAt(
      id: 2,
      title: 'Billingue 🌺',
      body:
          'Commence ta journée avec $minutes min de Baoulé ! 🇨🇮',
      hour: 8,
      minute: 0,
    );

    // Rappel si pas de connexion depuis 2 jours
    await _scheduleInactivityReminder();
  }

  Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'billingue_channel',
          'Billingue Rappels',
          channelDescription:
              'Rappels quotidiens pour apprendre le Baoulé',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleInactivityReminder() async {
    final scheduled = tz.TZDateTime.now(tz.local)
        .add(const Duration(days: 2));
    await _notifications.zonedSchedule(
      3,
      'Tu nous manques ! 😢',
      'Ça fait 2 jours. Reviens apprendre le Baoulé ! 🇨🇮',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'billingue_channel',
          'Billingue Rappels',
          channelDescription: 'Rappels d\'inactivité',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Notification immédiate de félicitation
  Future<void> showCongrats(String lessonTitle) async {
    await _notifications.show(
      10,
      'Leçon terminée ! 🏆',
      'Tu as complété "$lessonTitle". Continue comme ça !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'billingue_channel',
          'Billingue Rappels',
          channelDescription: 'Félicitations',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _getMessage(String objectif) {
    switch (objectif) {
      case 'Moyens':
        return 'Juste 5 min pour apprendre le Baoulé aujourd\'hui ! 🌺';
      case 'Regulier':
        return 'Tes 10 min de Baoulé t\'attendent ! 🇨🇮';
      case 'Sérieux':
        return 'Session de 15 min — deviens bilingue ! 💪';
      case 'Intense':
        return '20 min de Baoulé intensif aujourd\'hui ! 🔥';
      default:
        return 'Apprends le Baoulé aujourd\'hui ! 🌺';
    }
  }

  int _getMinutes(String objectif) {
    switch (objectif) {
      case 'Moyens':
        return 5;
      case 'Regulier':
        return 10;
      case 'Sérieux':
        return 15;
      case 'Intense':
        return 20;
      default:
        return 10;
    }
  }
}