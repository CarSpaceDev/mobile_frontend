import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState());
  final AuthService authService = AuthService();
  final ApiService apiService = ApiService.create();
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginStartEvent) {
      yield LoginStartState();
    } else if (event is NoSessionEvent) {
      yield LoggedOut();
    } else if (event is LoggedInEvent) {
      User user = await authService.currentUser();
      yield AuthorizationSuccess();
//      user = await getUserDataFromApi(user);
      yield LoggedIn(user);
    } else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      User user = await authService.loginGoogle();
      if (user != null) {
        yield AuthorizationSuccess();
        print("Logged in");
//        user = await getUserDataFromApi(user);
        yield LoggedIn(user);
      } else
        yield LoggedOut();
    } else if (event is LogInEmailEvent) {
      yield LoginInProgress();
      User user =
          await authService.signInWithEmail(event.email, event.password);
      print(user.toJson());
      print(user != null);
      if (user != null) {
        yield AuthorizationSuccess();
//        user = await getUserDataFromApi(user);
        print("Logged in!!!!");
        yield LoggedIn(user);
      } else
        yield LoggedOut();
    } else if (event is NavigateToEulaEvent) {
      yield NavToEula();
    } else if (event is NavigateToRegisterEvent) {
      yield NavToRegister();
    } else if (event is NavigateToLandingPageEvent) {
      yield NavToLandingPage();
    }
  }

  getUserDataFromApi(User user) async {
    try {
      final response =
          await apiService.requestUserInfo(user.jwt, user.toJson());
      if (response.statusCode == 201) {
        print('Decoding the response body');
        print(response.body.toString());
        user = user.fromJson(response.body);
        return user;
      } else if (response.statusCode == 403)
        print("JWT Error");
      else
        throw Error();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
