import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushMessagingService {
  FirebaseMessaging firebaseMessaging;
  String token;
  StreamController<Map<String, dynamic>> notificationsController;
  Stream notificationStream;

  PushMessagingService() {
    notificationsController = StreamController<Map<String, dynamic>>.broadcast();
    notificationStream = notificationsController.stream;
    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        notificationsController.add(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      print("Push Messaging Initialization Success");
      print(token);
      this.token = token;
    });
  }
}
