import 'dart:async';

import 'package:carspace/services/AuthService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../navigation.dart';
import '../serviceLocator.dart';

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
        if (message["data"]["recipient"] == locator<AuthService>().currentUser().uid) {
          if (!notificationShowing) {
            notificationShowing = true;
            showDialog(
                context: locator<NavigationService>().navigatorKey.currentContext,
                builder: (_) => AlertDialog(
                      actions: [
                        FlatButton(
                            onPressed: () {
                              locator<NavigationService>().goBack();
                              notificationShowing = false;
                            },
                            child: Text("Close"))
                      ],
                      actionsOverflowDirection: VerticalDirection.down,
                      content: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.notification_important,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                              Text(
                                message["notification"]["body"],
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ));
          }
        }
        notificationsController.add(message);
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
    firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      this.token = token;
    });
  }
}
