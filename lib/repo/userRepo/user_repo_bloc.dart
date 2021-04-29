import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/model/CSUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:equatable/equatable.dart';

part 'user_repo_event.dart';
part 'user_repo_state.dart';

class UserRepoBloc extends Bloc<UserRepoEvent, UserRepoState> {
  UserRepoBloc() : super(UserRepoInitial());
  StreamSubscription<DocumentSnapshot> user;
  bool licenseWarning = true;
  @override
  Stream<UserRepoState> mapEventToState(
    UserRepoEvent event,
  ) async* {
    if (event is InitializeUserRepo) {
      print("Initializing UserRepo");
      try {
        user = FirebaseFirestore.instance.collection("users").doc(event.uid).snapshots().listen((result) {
          CSUser u = CSUser.fromDoc(result);
          if (u.licenseExpiry != null) {
            if (u.licenseExpiry.isBefore(DateTime.now().add(Duration(days: 7)))) {
              if (licenseWarning) {
                try {
                  licenseWarning = false;
                  FirebaseFirestore.instance.collection("archive").doc(u.uid).collection("notifications").add(
                          CSNotification(
                              opened: false,
                              title: "Your license is expiring soon!",
                              dateCreated: DateTime.now(),
                              type: NotificationType.ExpiringLicense,
                              data: {
                            "message": "Your license will expire by ${formatDate(u.licenseExpiry, [
                              MM,
                              " ",
                              dd,
                              ", ",
                              yyyy,
                            ])}. Please update your license photo at the soonest possible time."
                          }).toJson());
                } catch (e) {}
              }
            }
          }
          if (result.exists) add(UpdateUserRepo(user: u));
        });
      } catch (e) {
        print("Initialize User Repo Error");
        print(e);
      }
    }
    if (event is UpdateUserRepo) {
      print("User Updated");
      yield UserRepoReady(user: event.user);
    }
    if (event is DisposeUserRepo) {
      print("UserRepoCalledDispose");
      await user.cancel();
    }
  }
}
