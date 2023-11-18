import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
int id = 0;

Future<void> setupLocalNotifications() async {
  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher")
  ));
}

void showNotification(String title, String body) {
  flutterLocalNotificationsPlugin.show(id++, title, body, const NotificationDetails(
    android: AndroidNotificationDetails('BirthdayReminder-Id', 'Recent Birthdays',
        channelDescription: 'Recent Birthdays'
    )
  ));
}