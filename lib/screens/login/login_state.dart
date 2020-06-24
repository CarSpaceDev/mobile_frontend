import 'package:carspace/model/User.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class InitialLoginState extends LoginState {}
class NavToRegister extends LoginState {}

class LoggingIn extends LoginState {}

class LoggedIn extends LoginState {
  final User user;
  LoggedIn(this.user) : super([user]);
}
