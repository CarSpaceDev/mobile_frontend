part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}
class EulaResponseEvent extends LoginEvent {
  final bool value;
  EulaResponseEvent({this.value});
  @override
  List<Object> get props => [value];
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

class NavigateToEulaEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoggedInGoogleFromEulaEvent extends LoginEvent {
  final CSUser user;
  LoggedInGoogleFromEulaEvent(this.user);
  @override
  List<Object> get props => [user];
}

class LoggedInEulaToGoogle extends LoginEvent {
  final CSUser user;
  LoggedInEulaToGoogle(this.user);
  @override
  List<Object> get props => [user];
}

class NavigateToLandingPageEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class NavigateToReturnScreen extends LoginEvent {
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

class SubmitRegistrationEvent extends LoginEvent {
  final _email;
  final _firstName;
  final _lastName;

  SubmitRegistrationEvent(this._email, this._firstName, this._lastName);

  @override
  List<Object> get props => [_email, _firstName, _lastName];
}
