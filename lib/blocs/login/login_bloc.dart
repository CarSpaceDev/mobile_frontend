import 'dart:async';

import 'package:carspace/model/User.dart';
import 'package:carspace/screens/login/RegistrationScreen.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/PushMessagingService.dart';
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
      User user = authService.currentUser();
      if (user != null) {
        //case where a user is in the google auth cache
        var userFromApi = (await apiService.checkExistence(uid: user.uid)).body["data"];
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
        //the register screen automatically populates data if it is a login via google event
        yield NavToRegister();
      } else {
        //false
        yield LoggedOut();
      }
    } else if (event is NavigateToEulaEvent) {
      yield ShowEulaScreen();
    }
    //V2 Update
    else if (event is GeneratePhoneCodeEvent) {
      User user = authService.currentUser();
      yield WaitingLogin(message: "Generating code");
      var result = await apiService.generateCode(uid: user.uid, phoneNumber: event.phoneNumber);
      if (result.statusCode == 200) {
        yield ShowPhoneCodeConfirmScreen();
      }
    }
    //V2 Update
    else if (event is AddVehicleEvent) {
      var payload = {
        "OR": event.OR,
        "CR": event.CR,
        "vehicleImage": event.vehicleImage,
        "make": event.make,
        "model": event.model,
        "plateNumber": event.plateNumber,
        "type": event.type,
        "color": event.color
      };
      yield WaitingLogin(message: "Adding vehicle");
      Response res = await apiService.addVehicle((authService.currentUser()).uid, payload);
      if (res.statusCode == 201) {
        if (event.fromHomeScreen) {
          navService.goBack();
        } else {
          navService.pushReplaceNavigateTo(HomeRoute);
        }
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
      User user = authService.currentUser();
      cache.put(user.email, {"skipVehicle": true});
      setPushTokenCache();
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
      User user = authService.currentUser();
      yield WaitingLogin(message: "Confirming code");
      var result = await apiService.confirmCode(uid: user.uid, code: event.code);
      if (result.statusCode == 200) {
        User currentUser = authService.currentUser();
        var userResult = await apiService.checkExistence(uid: currentUser.uid);
        CSUser user = CSUser.fromJson(userResult.body["data"]);
        yield checkUserDataForMissingInfo(user: user);
      } else {
        yield LoginError(message: result.error.toString());
      }
    }
    //V2 Update
    else if (event is NavigateToVehicleAddEvent) {
      yield ShowVehicleRegistration(fromHomeScreen: true);
    }
    //V2 Update
    else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      User user = await authService.loginGoogle();
      if (user != null) {
        //case where a user is in the google auth cache
        var userFromApi = (await apiService.checkExistence(uid: user.uid)).body["data"];
        if (userFromApi == null) {
          //if said user is not registered in db
          yield ShowEulaScreen();
        } else {
          //case where the user exists
          CSUser userData = CSUser.fromJson(userFromApi);
          yield checkUserDataForMissingInfo(user: userData);
        }
      } else
        yield LoggedOut();
    } else if (event is LogInEmailEvent) {
      yield LoginInProgress();
      User user = await authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        var userFromApi = (await apiService.checkExistence(uid: user.uid)).body["data"];
        if (userFromApi == null) {
          //if said user is not registered in db
          yield ShowEulaScreen();
        } else {
          //case where the user exists
          CSUser userData = CSUser.fromJson(userFromApi);
          yield checkUserDataForMissingInfo(user: userData);
        }
      } else
        yield LoggedOut();
    } else if (event is SubmitRegistrationEvent) {
      yield WaitingLogin(message: "Creating your account");
      var result = await apiService.registerUser(event.payload.toJson());
      if (result.statusCode == 201) {
        yield LoginInProgress();
        User user = authService.currentUser();
        CSUser userData;
        if (user == null) {
          user = await authService.signInWithEmail(event.payload.email, event.payload.password);
        }
        var userFromApi = (await apiService.checkExistence(uid: user.uid)).body["data"];
        userData = CSUser.fromJson(userFromApi);
        yield checkUserDataForMissingInfo(user: userData);
      }
    }
  }

  LoginState checkUserDataForMissingInfo({CSUser user}) {
    LoginState result;
    if (user.phoneNumber == null) {
      result = ShowPhoneNumberInputScreen();
    } else if (user.vehicles.length == 0) {
      var userSettings = cache.get(user.emailAddress);
      if (userSettings == null) {
        cache.put(user.emailAddress, {"skipVehicle": false});
        result = ShowVehicleRegistration();
      } else {
        if (userSettings["skipVehicle"] == true) {
          setPushTokenCache();
          navService.pushReplaceNavigateTo(HomeRoute);
        } else {
          result = ShowVehicleRegistration();
        }
      }
    } else {
      setPushTokenCache();
      navService.pushReplaceNavigateTo(HomeRoute);
    }
    return result;
  }

  setPushTokenCache() async {
    String pushToken = locator<PushMessagingService>().token;
    User currentUser = locator<AuthService>().currentUser();
    await locator<ApiService>().registerDevice(uid: currentUser.uid, token: pushToken);
  }
}
