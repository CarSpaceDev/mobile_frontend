import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/repo/notificationRepo/notification_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'NotificationWidget.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CSText(
              "Notifications",
              textType: TextType.H4,
            ),
          ),
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (BuildContext context, state) {
                if (state is NotificationsReady) {
                  print(state.notifications[0].toJson());
                  if (state.notifications.isEmpty)
                    return Text("No notifications at the moment");
                  else
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          for (CSNotification notification in state.notifications)
                            NotificationWidget(
                                notification: notification,
                                onTap: () {
                                  if(!notification.opened)
                                  context.bloc<NotificationBloc>().add(NotificationOpened(uid: notification.uid));
                                })
                        ],
                      ),
                    );
                } else
                  return Text("Getting notifications ... ");
              },
            ),
          ),
          CSTile(
            onTap: Navigator.of(context).pop,
            child: Icon(CupertinoIcons.xmark),
          )
        ],
      ),
    );
  }
}
