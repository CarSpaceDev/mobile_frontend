import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent();
}

class LoginAppleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginFacebookEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LogoutEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoggedInEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class NoSessionEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class GettingUserDataEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class AuthorizationSuccessEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}
class NavigateToRegisterEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}
