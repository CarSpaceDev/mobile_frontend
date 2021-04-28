part of 'user_repo_bloc.dart';

abstract class UserRepoState extends Equatable {
  const UserRepoState();
}

class UserRepoInitial extends UserRepoState {
  @override
  List<Object> get props => [];
}

class UserRepoReady extends UserRepoState {
  final CSUser user;
  UserRepoReady({this.user});
  @override
  List<Object> get props => [user];
}
