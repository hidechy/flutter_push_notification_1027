import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

//////////////////////////////////////////////
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    debugPrint('get some noti');
  }
}

//////////////////////////////////////////////

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await PushNotifications.init();
  await PushNotifications.localNotiInit();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      navigatorKey.currentState!.pushNamed('/message', arguments: message);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final payloadData = jsonEncode(message.data);

    debugPrint('get foreground noti');
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });

  runApp(const MyApp());
}

//////////////////////////////////////////////
final navigatorKey = GlobalKey<NavigatorState>();

//////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => const HomePage(),
        '/message': (context) => Message(),
      },
    );
  }
}

//////////////////////////////////////////////

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('HomePage'),
          ],
        ),
      ),
    );
  }
}

//

// ignore: avoid_classes_with_only_static_members
class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ///
  static Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      announcement: true,
    );

    final token = await _firebaseMessaging.getToken();
    debugPrint('token: $token');
  }

  ///
  static Future<void> localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );

    const initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');

    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsDarwin, linux: initializationSettingsLinux);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  ///
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!.pushNamed('/message', arguments: notificationResponse);
  }

  ///
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: payload);
  }
}

//////////////////////////////////////////////

// ignore: must_be_immutable
class Message extends StatelessWidget {
  Message({super.key});

  Map<dynamic, dynamic> payload = {};

  ///
  @override
  Widget build(BuildContext context) {
//    final notiData = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    final notiData = ModalRoute.of(context)!.settings.arguments;
    if (notiData is RemoteMessage) {
      payload = notiData.data;
    }
    if (notiData is NotificationResponse) {
      payload = jsonDecode(notiData.payload!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Noti Tapped')),
      body: SafeArea(child: Text(payload.toString())),
    );
  }
}
