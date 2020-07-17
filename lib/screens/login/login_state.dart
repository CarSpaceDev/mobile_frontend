part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitialState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginStartState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoggedOut extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginInProgress extends LoginState {
  @override
  List<Object> get props => [];
}

class AuthorizationSuccess extends LoginState {
  @override
  List<Object> get props => [];
}

class GettingUserData extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginNoFilter extends LoginState {
  final User user;
  LoginNoFilter(this.user);
  @override
  List<Object> get props => [user];
}

//final state
class LoggedIn extends LoginState {
  final User user;
  LoggedIn(this.user);
  @override
  List<Object> get props => [user];
}

class NavToRegister extends LoginState {
  @override
  List<Object> get props => [];
}

class NavToEula extends LoginState {
  @override
  List<Object> get props => [];
}

class NavToLandingPage extends LoginState {
  @override
  List<Object> get props => [];
}

class LogInEmailState extends LoginState {
  final String email;
  final String password;

  LogInEmailState({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}
