part of 'user_repo_bloc.dart';

abstract class UserRepoEvent extends Equatable {
  const UserRepoEvent();
}

class InitializeUserRepo extends UserRepoEvent {
  final String uid;
  InitializeUserRepo({this.uid});
  @override
  List<Object> get props => [uid];
}

class UpdateUserRepo extends UserRepoEvent {
  final CSUser user;
  UpdateUserRepo({this.user});
  @override
  List<Object> get props => [user];
}

class UserRepoErrorTrigger extends UserRepoEvent {
  UserRepoErrorTrigger();
  @override
  List<Object> get props => [];
}

class DisposeUserRepo extends UserRepoEvent {
  @override
  List<Object> get props => [];
}

