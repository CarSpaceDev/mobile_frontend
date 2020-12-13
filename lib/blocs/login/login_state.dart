part of '../../blocs/login/login_bloc.dart';

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

//V2 Usage
class LoggedOut extends LoginState {
  @override
  List<Object> get props => [];
}

//V2 Usage
class LoginError extends LoginState {
  final String message;
  LoginError({this.message});
  @override
  List<Object> get props => [message];
}

//V2 Usage
class ShowVehicleRegistration extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginInProgress extends LoginState {
  @override
  List<Object> get props => [];
}
//V2 Usage
class AuthorizationSuccess extends LoginState {
  @override
  List<Object> get props => [];
}

class GettingUserData extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginNoFilter extends LoginState {
  final CSUser user;
  LoginNoFilter(this.user);
  @override
  List<Object> get props => [user];
}

//final state
class LoggedIn extends LoginState {
  final CSUser user;
  LoggedIn(this.user);
  @override
  List<Object> get props => [user];
}

class GoogleToEulaState extends LoginState {
  final CSUser user;
  GoogleToEulaState(this.user);
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

//V2 Usage
class ShowEulaScreen extends LoginState {
  @override
  List<Object> get props => [];
}

//V2 Usage
class ShowPhoneNumberInputScreen extends LoginState {
  @override
  List<Object> get props => [];
}

//V2 Usage
class ShowPhoneCodeConfirmScreen extends LoginState {
  @override
  List<Object> get props => [];
}

//V2 Usage
class WaitingLogin extends LoginState {
  final String message;
  WaitingLogin({this.message});
  @override
  List<Object> get props => [message];
}


class NavToLandingPage extends LoginState {
  @override
  List<Object> get props => [];
}

class NavToTestPage extends LoginState {
  final String email;
  final String firstName;
  final String lastName;

  NavToTestPage(this.email, this.firstName, this.lastName);

  @override
  List<Object> get props => [email];
}

class LogInEmailState extends LoginState {
  final String email;
  final String password;

  LogInEmailState({this.email, this.password});

  @override
  List<Object> get props => [email, password];
}

class SubmittedState extends LoginState {
  @override
  List<Object> get props => [];
}

class VerificationState extends LoginState {
  final _email;

  VerificationState(this._email);

  CSUser get getEmail => _email;

  @override
  List<Object> get props => [_email];
}

class NavToReturnScreen extends LoginState {
  final String email;
  final String firstName;
  final String lastName;

  NavToReturnScreen(this.email, this.firstName, this.lastName);

  @override
  List<Object> get props => [email, firstName, lastName];
}
