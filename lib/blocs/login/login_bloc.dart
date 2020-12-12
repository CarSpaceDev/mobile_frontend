import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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
          cache.put("user", userData.body["data"]);
          if (userData.body["data"]['phoneNumber'] == null) {
            yield ShowPhoneNumberInputScreen();
          }
          //todo else check for the other stuff like car registration
        }
      }
      else {
        yield LoggedOut();
      }
    }
    else if (event is EulaResponseEvent){
      if (event.value){
        //true
        //It is implied that when the EulaResponseEvent is triggered, the user does not exist in database
        //Check if the firebase user is null then show the email/pass registration if that is the case
        //else run the api endpoint that generates the user and check for the phone number
        User currentUser = await authService.currentUser();
        if (currentUser!=null){
          //a google first sign in event
          yield WaitingLogin(message: "Creating account.");
          print("Eula accepted/Google First Sign");
          var userResponse = await apiService.registerViaGoogle(uid:currentUser.uid);
          if (userResponse.statusCode==200) {
            yield WaitingLogin(message: "Account created.");
            print(userResponse.body['data']);
            cache.put("user", userResponse.body["data"]);
            if (userResponse.body["data"]['phoneNumber'] == null) {
              yield ShowPhoneNumberInputScreen();
            }
          }
          else yield LoginError(message: "Account creation failure");
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
    //V2 Update
    else if (event is GeneratePhoneCodeEvent){
      User user = await authService.currentUser();
      yield WaitingLogin(message:"Generating code");
      var result = await apiService.generateCode(uid:user.uid, phoneNumber:event.phoneNumber);
      if (result.statusCode==200){
        yield ShowPhoneCodeConfirmScreen();
      }
    }
    //V2 Update
    else if (event is RestartLogin){
      yield WaitingLogin(message:"Please wait");
      await authService.logOut();
      cache.put("user", null);
      yield LoggedOut();
    }
    //V2 Update
    //todo Handle 500 errors
    else if (event is ConfirmPhoneCodeEvent){
      User user = await authService.currentUser();
      yield WaitingLogin(message:"Confirming code");
      var result = await apiService.confirmCode(uid:user.uid, code:event.code);
      if (result.statusCode==200){
        print("Code confirmed");
        // yield ShowPhoneCodeConfirmScreen();
      }
      else {
        print(result.error);
        print(result.error.toString());
        yield LoginError(message: result.error.toString());
      }
    }
    else if (event is LoggedInEvent) {
      User user = await authService.currentUser();
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



  checkUserDataForMissingInfo({String uid, Map<String,dynamic> user}){

  }
}
