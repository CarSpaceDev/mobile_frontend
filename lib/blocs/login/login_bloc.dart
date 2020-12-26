import 'dart:async';

import 'package:carspace/model/User.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/UploadService.dart';
import 'package:chopper/chopper.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final UploadService uploadService = locator<UploadService>();
  final cache = Hive.box("localCache");
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    //V2 Update
    if (event is LoginStartEvent) {
      //Start of login flow
      //1. Check for a logged in user.
      //2. If none exists, show login screen
      //3. Else, get data from server
      //4. Evaluate data, if there are issues with the data switch screens.
      //checking for a cached user
      User user = await authService.currentUser();
      if (user != null) {
        //case where a user is in the google auth cache
        var userFromApi =
            (await apiService.checkExistence(uid: user.uid)).body["data"];
        if (userFromApi == null) {
          //if said user is not registered in db
          yield ShowEulaScreen();
        } else {
          //case where the user exists
          CSUser userData = CSUser.fromJson(userFromApi);
          yield checkUserDataForMissingInfo(user: userData);
        }
      } else {
        //head to login screen
        yield LoggedOut();
      }
    } else if (event is EulaResponseEvent) {
      if (event.value) {
        //true
        //It is implied that when the EulaResponseEvent is triggered, the user does not exist in database
        //Check if the firebase user is null then show the email/pass registration if that is the case
        //else run the api endpoint that generates the user and check for the phone number
        User currentUser = await authService.currentUser();
        if (currentUser != null) {
          // //a google first sign in event
          // yield WaitingLogin(message: "Creating account.");
          print("Eula accepted/Google First Sign");
          yield NavToRegister();
          // var userResponse =
          //     await apiService.registerViaGoogle(uid: currentUser.uid);
          // if (userResponse.statusCode == 200) {
          //   yield WaitingLogin(message: "Account created.");
          //   CSUser userData = CSUser.fromJson(userResponse.body["data"]);
          //   yield checkUserDataForMissingInfo(user: userData);
          // } else
          //   yield LoginError(message: "Account creation failure");
        } else {
          print("JESSSSSSSSSSS!!!!!!!!!!!!");
          yield NavToRegister();
          //a user/pass registration event
        }
      } else {
        //false
        yield LoggedOut();
      }
    } else if (event is NavigateToEulaEvent) {
      print("event is navigateToeula");
      yield ShowEulaScreen();
    }
    //V2 Update
    else if (event is GeneratePhoneCodeEvent) {
      User user = await authService.currentUser();
      yield WaitingLogin(message: "Generating code");
      var result = await apiService.generateCode(
          uid: user.uid, phoneNumber: event.phoneNumber);
      if (result.statusCode == 200) {
        yield ShowPhoneCodeConfirmScreen();
      }
    }
    //V2 Update
    else if (event is AddVehicleEvent) {
      print("Uploading Images");
      yield WaitingLogin(message: "Uploading Images");
      List<Response<dynamic>> result = await Future.wait([
        uploadService.uploadItemImage(event.OR),
        uploadService.uploadItemImage(event.CR)
      ]);
      print("Upload Image End");
      var payload = {
        "OR": result[0].body,
        "CR": result[1].body,
        "plateNumber": event.plateNumber,
        "type": event.type,
        "color": event.color
      };
      print(payload);
      print("Sending payload");
      yield WaitingLogin(message: "Registering vehicle");
      Response res = await apiService.addVehicle(
          (await authService.currentUser()).uid, payload);
      print(res.body);
      print(res.statusCode);
      if (res.statusCode == 201) {
        navService.pushReplaceNavigateTo(HomeRoute);
      } else
        yield LoginError(message: res.error.toString());
    }
    //V2 Update
    else if (event is RestartLoginEvent) {
      yield WaitingLogin(message: "Please wait");
      await authService.logOut();
      cache.put("user", null);
      yield LoggedOut();
    }
    //V2 Update
    else if (event is SkipVehicleAddEvent) {
      User user = await authService.currentUser();
      cache.put(user.email, {"skipVehicle": true});
      navService.pushReplaceNavigateTo(HomeRoute);
    }
    //V2 Update
    else if (event is LogoutEvent) {
      yield WaitingLogin(message: "Please wait");
      await authService.logOut();
      cache.put("user", null);
      yield LoggedOut();
    }
    //V2 Update
    else if (event is ConfirmPhoneCodeEvent) {
      User user = await authService.currentUser();
      yield WaitingLogin(message: "Confirming code");
      var result =
          await apiService.confirmCode(uid: user.uid, code: event.code);
      if (result.statusCode == 200) {
        print("Code confirmed");
        User currentUser = await authService.currentUser();
        var userResult = await apiService.checkExistence(uid: currentUser.uid);
        CSUser user = CSUser.fromJson(userResult.body["data"]);
        yield checkUserDataForMissingInfo(user: user);
      } else {
        print(result.error);
        yield LoginError(message: result.error.toString());
      }
    }
    //V2 Update??????????
    else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      User user = await authService.loginGoogle();
      //case where a user is in the google auth cache
      var userFromApi =
          (await apiService.checkExistence(uid: user.uid)).body["data"];
      if (userFromApi == null) {
        //if said user is not registered in db
        yield ShowEulaScreen();
      } else {
        //case where the user exists
        CSUser userData = CSUser.fromJson(userFromApi);
        yield checkUserDataForMissingInfo(user: userData);
      }
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
    }
  }

  LoginState checkUserDataForMissingInfo({CSUser user}) {
    LoginState result;
    if (user.phoneNumber == null) {
      result = ShowPhoneNumberInputScreen();
    } else if (user.vehicles.length == 0) {
      var userSettings = cache.get(user.emailAddress);
      print(userSettings);
      if (userSettings == null) {
        cache.put(user.emailAddress, {"skipVehicle": false});
        result = ShowVehicleRegistration();
      } else {
        if (userSettings["skipVehicle"] == true)
          navService.pushReplaceNavigateTo(HomeRoute);
        else {
          result = ShowVehicleRegistration();
        }
      }
    } else
      navService.pushReplaceNavigateTo(HomeRoute);
    return result;
  }
}
