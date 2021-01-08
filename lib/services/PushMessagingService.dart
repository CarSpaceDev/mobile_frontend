import 'package:firebase_messaging/firebase_messaging.dart';

class PushMessagingService {
  FirebaseMessaging firebaseMessaging;
  String token;

  PushMessagingService() {
    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
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
      print("Push Messaging Initialization Success: $token");
      this.token = token;
    });
  }
}
