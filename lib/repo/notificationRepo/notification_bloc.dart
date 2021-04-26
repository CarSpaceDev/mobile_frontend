import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/Home/NotificationWidget.dart';
import 'package:carspace/screens/Home/PopupNotifications.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial());

  StreamSubscription<QuerySnapshot> notifications;
  CollectionReference repoReference;
  List<CSNotification> nRepo = [];
  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    if (event is InitializeNotificationRepo) {
      repoReference = FirebaseFirestore.instance
          .collection("archive")
          .doc(event.uid)
          .collection("notifications");
      notifications = repoReference
          .orderBy("dateCreated", descending: true)
          .snapshots()
          .listen((result) {
        List<CSNotification> temp = [];
        for (QueryDocumentSnapshot r in result.docs) {
          temp.add(CSNotification.fromDoc(r));
        }
        if (temp.length > nRepo.length && nRepo.isNotEmpty) {
          nRepo = temp;
          add(NewNotificationReceived());
        } else {
          nRepo = temp;
          add(NotificationsUpdated(notifications: nRepo));
        }
      });
    }
    if (event is NewNotificationReceived) {
      print("New notification added to the collection");
      print(nRepo[0].type);
      PopupNotifications.showNotificationDialog(
          locator<NavigationService>().navigatorKey.currentContext,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NotificationWidget(notification: nRepo[0]),
              // CSTile(
              //   onTap: () {
              //     print("some actions");
              //   },
              //   color: TileColor.Primary,
              //   child: CSText(
              //     "SOME ACTIONS HERE",
              //     textType: TextType.Button,
              //   ),
              // )
            ],
          ),
          barrierDismissible: true);

      add(NotificationsUpdated(notifications: nRepo));
    }
    if (event is NotificationOpened) {
      print(event.uid);
      print("OPENING NOTIFICATIONS");
      await repoReference.doc(event.uid).update({"opened": true});
    }
    if (event is NotificationsUpdated) {
      print("UPDATING NOTIFICATIONS");
      yield NotificationsReady(notifications: event.notifications);
    }
    if (event is DisposeNotificationRepo) {
      print("VehicleRepoCalledDispose");
      await notifications.cancel();
    }
  }
}
