import 'dart:async';

import 'package:carspace/model/Notification.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/PushMessagingService.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';
import 'NotificationList.dart';

class NotificationLinkWidget extends StatefulWidget {
  @override
  _NotificationLinkWidgetState createState() => _NotificationLinkWidgetState();
}

class _NotificationLinkWidgetState extends State<NotificationLinkWidget> {
  bool newNotification = false;
  StreamSubscription notificationSubscription;

  @override
  void initState() {
    locator<ApiService>().getNotifications(uid: locator<AuthService>().currentUser().uid).then((v) {
      if (v.statusCode == 200) {
        List<Map<String, dynamic>>.from(v.body).forEach((v) {
          NotificationFromApi temp = NotificationFromApi.fromJson(v);
          if (temp.opened == false) {
            setState(() {
              newNotification = true;
            });
          }
        });
      } else {
        print(v.error);
      }
    }).catchError((err) {
      print(err);
    });
    notificationSubscription = locator<PushMessagingService>().notificationStream.listen((event) {
      setState(() {
        newNotification = true;
      });
      // _showToast();
    });
    super.initState();
  }

  @override
  void dispose() {
    notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return newNotification
        ? IconButton(
            color: Colors.redAccent, onPressed: showNotificationDialog, icon: Icon(Icons.notification_important))
        : IconButton(color: Colors.white, onPressed: showNotificationDialog, icon: Icon(Icons.notifications));
  }

  showNotificationDialog() {
    setState(() {
      newNotification = false;
    });
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: NotificationList(),
      ),
    ).then((value) => locator<ApiService>().getNotifications(uid: locator<AuthService>().currentUser().uid).then((v) {
          if (v.statusCode == 200) {
            List<Map<String, dynamic>>.from(v.body).forEach((v) {
              NotificationFromApi temp = NotificationFromApi.fromJson(v);
              if (temp.opened == false) {
                setState(() {
                  newNotification = true;
                });
              }
            });
          } else {
            print(v.error);
          }
        }).catchError((err) {
          print(err);
        }));
  }

  _showToast() {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: const Text('New Notification'),
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              Scaffold.of(context).hideCurrentSnackBar();
              showNotificationDialog();
            }),
      ),
    );
  }
}
