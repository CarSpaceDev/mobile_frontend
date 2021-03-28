part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

//used by v2
class EulaResponseEvent extends LoginEvent {
  final bool value;
  EulaResponseEvent({this.value});
  @override
  List<Object> get props => [value];
}

//used by v2
class GeneratePhoneCodeEvent extends LoginEvent {
  final String phoneNumber;
  GeneratePhoneCodeEvent({this.phoneNumber});
  @override
  List<Object> get props => [phoneNumber];
}

//used by v2
class ConfirmPhoneCodeEvent extends LoginEvent {
  final String code;
  ConfirmPhoneCodeEvent({this.code});
  @override
  List<Object> get props => [code];
}

//used by v2
class RestartLoginEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

//used by v2
class SkipVehicleAddEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

//used by v2
class AddVehicleEvent extends LoginEvent {
  final String plateNumber;
  final int type;
  final String color;
  // ignore: non_constant_identifier_names
  final String OR;
  // ignore: non_constant_identifier_names
  final String CR;
  final String vehicleImage;
  final String make;
  final String model;
  final bool fromHomeScreen;
  // ignore: non_constant_identifier_names
  AddVehicleEvent(
      {this.plateNumber,
      this.type,
      this.color,
      this.OR,
      this.CR,
      this.vehicleImage,
      this.make,
      this.model,
      this.fromHomeScreen});
  @override
  List<Object> get props => [plateNumber, type, color, OR, CR, make, model];
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

class NavigateToVehicleAddEvent extends LoginEvent {
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
  final RegistrationPayload payload;

  SubmitRegistrationEvent(this.payload);

  @override
  List<Object> get props => [this.payload];
}
