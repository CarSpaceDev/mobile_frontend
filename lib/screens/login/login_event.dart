import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class NavRegisterEvent extends LoginEvent {}
class LoginFacebook extends LoginEvent {}
class LoginGoogle extends LoginEvent {}
class Logout extends LoginEvent {}