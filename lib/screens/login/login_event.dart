part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}


class LoginStartEvent extends LoginEvent {
  @override
  List<Object> get props => [];
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

class LogInEmailEvent extends LoginEvent {
  final String email;
  final String password;

  LogInEmailEvent({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}
