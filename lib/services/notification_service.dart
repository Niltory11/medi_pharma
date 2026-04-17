import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showExpiryNotification(String medicineName) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'expiry_channel',
        'Expiry Alerts',
        channelDescription: 'Alerts for near-expiry medicines',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      0,
      '⚠️ Near Expiry Alert',
      '$medicineName is expiring within 30 days!',
      details,
    );
  }
}