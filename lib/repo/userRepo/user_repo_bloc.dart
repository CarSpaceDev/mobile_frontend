import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSUser.dart';
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
      print("Initializing UserRepo");
      try {
        user = FirebaseFirestore.instance.collection("users").doc(event.uid).snapshots().listen((result) {
          if (result.exists) add(UpdateUserRepo(user: CSUser.fromDoc(result)));
        });
      } catch (e) {
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
