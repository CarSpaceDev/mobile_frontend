import 'package:carspace/model/User.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginState extends Equatable {
  LoginState();
}

//initialState

class LoginInitialState extends LoginState {
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

class LogInEmailState extends LoginState {
  final String email;
  final String password;

  LogInEmailState({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}
