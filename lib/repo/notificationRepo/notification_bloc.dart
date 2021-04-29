import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/screens/Notifications/NotificationWidget.dart';
import 'package:carspace/screens/Vehicles/VehicleAddAuthDetails.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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
      try {
        repoReference = FirebaseFirestore.instance.collection("archive").doc(event.uid).collection("notifications");
        notifications = repoReference.orderBy("dateCreated", descending: true).snapshots().listen((result) {
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
      } catch (e) {
        print("Initialize Notification Repo Error");
        print(e);
      }
    }
    if (event is NewNotificationReceived) {
      print("New notification added to the collection");
      switch (nRepo.first.type) {
        case NotificationType.VerificationRequest:
          PopupNotifications.showNotificationDialog(locator<NavigationService>().navigatorKey.currentContext,
              barrierDismissible: true, child: VehicleAddAuthDetails(code: nRepo.first.data["code"]));
          break;
        case NotificationType.Info:
        case NotificationType.ExpiringVehicle:
        case NotificationType.ExpiringLicense:
          PopupNotifications.showNotificationDialog(locator<NavigationService>().navigatorKey.currentContext,
              barrierDismissible: true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: NotificationWidget(
                    notification: nRepo.first,
                    onTap: () {
                      if (!nRepo.first.opened)
                        locator<NavigationService>()
                            .navigatorKey
                            .currentContext
                            .read<NotificationBloc>()
                            .add(NotificationOpened(uid: nRepo.first.uid));
                    }),
              ));
          break;
      }

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
      print("NotificationRepoCalledDispose");
      await notifications.cancel();
    }
  }
}
