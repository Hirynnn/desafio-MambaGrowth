import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(
      tz.getLocation('America/Sao_Paulo'),
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(
      settings: settings,
    );
  }

  Future<void> requestPermission() async {
    final androidImplementation =
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showFastingStartedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      'Jejum',
      channelDescription:
      'Notificações relacionadas ao jejum.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(
      id: 99,
      title: 'Jejum iniciado!',
      body: 'Seu período de jejum começou. Bom trabalho!',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> scheduleFastingEndNotification(
      DateTime endTime,
      ) async {
    await cancelFastingEndNotification();

    const androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      'Jejum',
      channelDescription:
      'Notificações relacionadas ao jejum.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final scheduledDate = tz.TZDateTime.from(
      endTime,
      tz.local,
    );

    await notificationsPlugin.zonedSchedule(
      id: 100,
      title: 'Jejum finalizado!',
      body:
      'Seu período de jejum terminou. Hora de se alimentar!',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelFastingEndNotification() async {
    await notificationsPlugin.cancel(
      id: 100,
    );
  }
}