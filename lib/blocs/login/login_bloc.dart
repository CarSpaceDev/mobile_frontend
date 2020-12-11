import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../../navigation.dart';
import '../../serviceLocator.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState());
  final AuthService authService = locator<AuthService>();
  final ApiService apiService = locator<ApiService>();
  final NavigationService navService = locator<NavigationService>();
  final cache = Hive.box("localCache");
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginStartEvent) {
      //Start of login flow
      //1. Check for a logged in user.
      //2. If none exists, show login screen
      //3. Else, get data from server
      //4. Evaluate data, if there are issues with the data switch screens.
      User user = await authService.currentUser();
      print("Current user");
      print(user);
      if (user!=null){
        final userData = await apiService.checkExistence(uid:user.uid);
        print(userData.body);
        if(userData.body["data"]==null){
          //case where user does not exist
          yield ShowEulaScreen();
        }
        else{
          //case where the user exists
          //cache the user data for later
          cache.put("user", userData.body);
          //todo HANDLE THIS CASE
        }
      }
      else {
        yield LoggedOut();
      }
    }
    else if (event is EulaResponseEvent){
      if (event.value){
        //true
        //check if this is a first login event by checking the existing user
        //if the user is null then show the email/pass registration
        //else run the api endpoint that generates the user and check for the phone number
        var currentUser = await authService.currentUser();
        if (currentUser!=null){
          //a google first sign in event

        }
        else{
          //a user/pass registration event
        }
      }
      else {
        //false
        yield LoggedOut();
      }
    }
    else if (event is LoggedInEvent) {
      CSUser user = await authService.currentUser();
      yield AuthorizationSuccess();
//      user = await getUserDataFromApi(user);
      navService.pushReplaceNavigateTo(HomeRoute);
    } else if (event is LoggedInEulaToGoogle) {
      apiService.registerUser(event.user.toJson());
      yield AuthorizationSuccess();
      yield LoggedIn(event.user);
    } else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      CSUser user = await authService.loginGoogle();
      print(user.toJson());
      final userData = await apiService.checkExistence(uid:user.uid);
      print(userData.body);
      if (user != null) {
        if (userData.body["data"]==null) {
          yield GoogleToEulaState(user);
        } else {
          yield AuthorizationSuccess();
          print("Logged in");
          navService.pushReplaceNavigateTo(HomeRoute);
        }
      } else
        yield LoggedOut();
    } else if (event is LogInEmailEvent) {
      yield LoginInProgress();
      CSUser user =
          await authService.signInWithEmail(event.email, event.password);
      print(user.toJson());
      print(user != null);
      if (user != null) {
        yield AuthorizationSuccess();
//        user = await getUserDataFromApi(user);
        print("Logged in!!!!");
        navService.pushReplaceNavigateTo(HomeRoute);
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

  getUserDataFromApi(CSUser user) async {
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
