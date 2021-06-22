import 'dart:async';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushMessagingService {
  FirebaseMessaging firebaseMessaging;
  String token;
  StreamController<Map<String, dynamic>> notificationsController;
  Stream notificationStream;
  bool notificationShowing = false;
  PushMessagingService() {
    notificationsController = StreamController<Map<String, dynamic>>.broadcast();
    notificationStream = notificationsController.stream;
    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (message["data"]["recipient"] == locator<AuthService>().currentUser().uid)
          notificationsController.add(message);
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );
    firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      this.token = token;
    });
  }
}
