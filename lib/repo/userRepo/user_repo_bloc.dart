import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'user_repo_event.dart';
part 'user_repo_state.dart';

class UserRepoBloc extends Bloc<UserRepoEvent, UserRepoState> {
  UserRepoBloc() : super(UserRepoInitial());
  StreamSubscription<DocumentSnapshot> user;

  @override
  Stream<UserRepoState> mapEventToState(
    UserRepoEvent event,
  ) async* {
    if (event is InitializeUserRepo) {
      if (user != null) {
        user.cancel();
      }
      user = FirebaseFirestore.instance.collection("users").doc(event.uid).snapshots().listen((result) {
        if (result.exists)
          add(UpdateUserRepo(user: CSUser.fromDoc(result)));
        else
          add(UserRepoErrorTrigger());
      });
    }
    if (event is UpdateUserRepo) {
      print("New update");
      // print(event.user.toJson());
      yield UserRepoReady(user: event.user);
    }
    if (event is DisposeUserRepo) {
      print("UserRepoCalledDispose");
      await user.cancel();
    }
    if (event is UserRepoErrorTrigger) {
      yield UserRepoError();
    }
  }
}
