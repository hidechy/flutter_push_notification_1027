import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

//////////////////////////////////////////////
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('get some noti');
  }
}

//////////////////////////////////////////////

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  PushNotifications.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      navigatorKey.currentState!.pushNamed('/message', arguments: message);
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
        '/message': (context) => const Message(),
      },
    );
  }
}

//////////////////////////////////////////////

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

//////////////////////////////////////////////

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  ///
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    print('token: ${token}');
  }
}

//////////////////////////////////////////////

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    final notiData = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    return Scaffold(
      appBar: AppBar(title: Text('Noti Tapped')),
      body: SafeArea(child: Text(notiData.data.toString())),
    );
  }
}
