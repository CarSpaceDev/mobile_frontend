import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:carspace/services/AuthService.dart';

final AuthService _authService = AuthService();

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => InitialLoginState();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is NavRegisterEvent) {
      yield NavToRegister();
    }
  }
}
