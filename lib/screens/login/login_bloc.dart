import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/screens/repository/submitRepo.dart';
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
    } else if (event is LoggedInEulaToGoogle) {
      apiService.registerUser(event.user.toJson());
      yield AuthorizationSuccess();
      yield LoggedIn(event.user);
    } else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      User user = await authService.loginGoogle();
      print(user.toJson());
      final result = user.email;
      print(result);
      final testResult = await apiService.getUserEmails({'email': result});
      final checkBody = testResult.body;
      if (user != null) {
        if (checkBody.isEmpty) {
          yield GoogleToEulaState(user);
          // apiService.registerUser(user.toJson());
//        user = await getUserDataFromApi(user);
        } else {
          yield AuthorizationSuccess();
          print("Logged in");
          yield LoggedIn(user);
        }
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
    } else if (event is SubmitRegistrationEvent) {
      yield LoginInProgress();
      ApiService apiService = ApiService.create();
      final testResult =
          await apiService.getUserEmails({'email': event._email});
      final result = testResult.body;
      print(result);
      if (result.isEmpty)
        yield NavToTestPage(event._email, event._firstName, event._lastName);
      else {
        yield NavToReturnScreen(
            event._email, event._firstName, event._lastName);
      }
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
