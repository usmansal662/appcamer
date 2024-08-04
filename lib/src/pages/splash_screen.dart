import 'package:camery/google%20ads/adservice.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/pages/onboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../utils/apputils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {}

  return Future<void>.value();
}

void showNotification({String? title, String? body}) {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'notification', 'Channel for notification',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker',
      playSound: true);

  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics,
      payload: 'Custom_Sound');
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/splash-bg.png'),
                fit: BoxFit.fill)),
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GPS Photo With',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Map & Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Capture the World: Where Every Photo\nTells a Place',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 17,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: EdgeInsets.only(bottom: Get.height * 0.02),
                  child: const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 30,
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.1),
                child: Image.asset(
                  'assets/images/surface.png',
                  height: 100,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.15),
                child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            0, -40 * (0.5 - (_controller.value - 0.5).abs())),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/bounce.png',
                      height: 140,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    super.initState();
    checkForInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {});
    registerNotification();

    if (!AppUtils.isSubscribed) {
      if (AdServices.welcomScreenInterstitial == null &&
          !AppUtils.isSubscribed &&
          splash_screen_interstitial) {
        AdServices.loadwelcomScreenInterstitial();
      }
    } else {
      Future.delayed(const Duration(seconds: 4)).then((value) {
        Get.off(
          () => const OnBoard(),
        );
      });
    }
  }

  checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {}
  }

  registerNotification() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int? id, String? title, String? body, String? payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      RemoteNotification notification = message!.notification!;
      AndroidNotification? android = message.notification?.android!;
      if (android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'notification',
              'Channel for notification',
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }
}
