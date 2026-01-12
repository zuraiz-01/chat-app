import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String messageChannelId = 'high_importance_channel';
  static const String callChannelId = 'call_channel';

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          messageChannelId,
          'Messages',
          description: 'Message notifications',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          callChannelId,
          'Calls',
          description: 'Incoming call notifications',
          importance: Importance.max,
        ),
      );
    }
  }

  static Future<void> showFromMessage(RemoteMessage message) async {
    final data = message.data;
    final type = data['type']?.toString();

    final title = message.notification?.title ?? data['title']?.toString();
    final body = message.notification?.body ?? data['body']?.toString();

    if (title == null && body == null) {
      return;
    }

    final isCall = type == 'call';
    final androidDetails = AndroidNotificationDetails(
      isCall ? callChannelId : messageChannelId,
      isCall ? 'Calls' : 'Messages',
      channelDescription:
          isCall ? 'Incoming call notifications' : 'Message notifications',
      importance: isCall ? Importance.max : Importance.high,
      priority: isCall ? Priority.max : Priority.high,
      fullScreenIntent: isCall,
      category: isCall ? AndroidNotificationCategory.call : null,
      visibility: NotificationVisibility.public,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
