import 'dart:async';

import 'package:carspace/repo/notificationRepo/notification_bloc.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'NotificationList.dart';

class NotificationLinkWidget extends StatefulWidget {
  @override
  _NotificationLinkWidgetState createState() => _NotificationLinkWidgetState();
}

class _NotificationLinkWidgetState extends State<NotificationLinkWidget> {
  bool newNotification = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (BuildContext context, state) {
        if (state is NotificationsReady) {
          for (var i = 0; i < state.notifications.length; i++) {
            if (state.notifications[i].opened != true)
              return IconButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    PopupNotifications.showNotificationDialog(context,
                        child: NotificationList(), barrierDismissible: true);
                  },
                  icon: Icon(Icons.notification_important));
          }
          return IconButton(
              color: Colors.white,
              onPressed: () {
                PopupNotifications.showNotificationDialog(context, child: NotificationList(), barrierDismissible: true);
              },
              icon: Icon(Icons.notifications));
        }
        return IconButton(
            color: Colors.white,
            onPressed: () {
              PopupNotifications.showNotificationDialog(context, child: NotificationList(), barrierDismissible: true);
            },
            icon: Icon(Icons.notifications));
      },
    );
  }
}
