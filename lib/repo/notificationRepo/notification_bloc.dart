import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial());

  StreamSubscription<QuerySnapshot> notifications;
  CollectionReference repoReference;
  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    if (event is InitializeNotificationRepo) {
      repoReference = FirebaseFirestore.instance.collection("archive").doc(event.uid).collection("notifications");
      notifications = repoReference.orderBy("dateCreated", descending: true).snapshots().listen((result) {
        List<CSNotification> nRepo = [];
        for (QueryDocumentSnapshot r in result.docs) {
          nRepo.add(CSNotification.fromDoc(r));
        }
        add(NotificationsUpdated(notifications: nRepo));
      });
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
