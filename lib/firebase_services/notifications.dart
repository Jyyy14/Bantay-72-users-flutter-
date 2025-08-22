// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundhandler(RemoteMessage message) async {
  await NotificationsService.instance.setupFlutterNotifications();
  await NotificationsService.instance.showNotif(message);
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _localnotifs = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotifInit = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundhandler);
    await _requestPermission();
    await _setupMessageHandlers();

    final token = await _messaging.getToken();
    print('FCM Token: ${token}');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permissio status: ${settings.authorizationStatus} ');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotifInit) {
      return;
    }

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localnotifs
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initSettings = InitializationSettings(android: initSettingsAndroid);

    await _localnotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isFlutterLocalNotifInit = true;
  }

  Future<void> showNotif(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    // Fallback to data if notification payload is null
    final title = notification?.title ?? message.data['title'];
    final body = notification?.body ?? message.data['body'];

    if (title == null || body == null) {
      print('Notification title or body is missing.');
      return;
    }

    await _localnotifs.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) {
      showNotif(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initalmessage = await _messaging.getInitialMessage();
    if (initalmessage != null) {
      _handleBackgroundMessage(initalmessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {}
  }
}
