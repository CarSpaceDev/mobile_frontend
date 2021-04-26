import 'dart:async';

import 'package:carspace/model/User.dart';
import 'package:carspace/repo/notificationRepo/notification_bloc.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/screens/DriverScreens/Vehicles/VehicleRegistrationScreen.dart';
import 'package:carspace/screens/Login/RegistrationScreen.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/PushMessagingService.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final cache = Hive.box("localCache");
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    //V2 Update
    if (event is LoginStartEvent) {
      User user = authService.currentUser();
      if (user != null) {
        try {
          var userFromApi =
              (await apiService.checkExistence(uid: user.uid)).body["data"];
          if (userFromApi == null) {
            yield ShowEulaScreen();
          } else {
            CSUser userData = CSUser.fromJson(userFromApi);
            yield checkUserDataForMissingInfo(user: userData);
          }
        } catch (e) {
          yield LoginError(message: "Error retrieving user data, please login");
        }
      } else {
        //head to login screen
        yield LoggedOut();
      }
    } else if (event is EulaResponseEvent) {
      if (event.value) {
        yield NavToRegister();
      } else {
        await authService.logOut();
        yield LoggedOut();
      }
    } else if (event is NavigateToEulaEvent) {
      yield ShowEulaScreen();
    }
    //V2 Update
    else if (event is GeneratePhoneCodeEvent) {
      User user = authService.currentUser();
      yield WaitingLogin(message: "Generating code");
      try {
        var result = await apiService.generateCode(
            uid: user.uid, phoneNumber: event.phoneNumber);
        if (result.statusCode == 200) {
          yield ShowPhoneCodeConfirmScreen();
        } else {
          showCodeGenerationErrorDialog();
        }
      } catch (e) {
        showCodeGenerationErrorDialog();
      }
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
      cache.put(user.uid, {"skipVehicle": true});
      setPushTokenCache();
      startRepos(uid: user.uid);
      navService.pushReplaceNavigateTo(DashboardRoute);
    }
    //V2 Update
    else if (event is LogoutEvent) {
      yield WaitingLogin(message: "Please wait");
      await apiService.unregisterDevice(
          uid: authService.currentUser().uid, token: locator<PushMessagingService>().token);
      navService.navigatorKey.currentContext.bloc<UserRepoBloc>().add(DisposeUserRepo());
      navService.navigatorKey.currentContext.bloc<VehicleRepoBloc>().add(DisposeVehicleRepo());
      navService.navigatorKey.currentContext.bloc<NotificationBloc>().add(DisposeNotificationRepo());
      navService.navigatorKey.currentContext.bloc<WalletBloc>().add(DisposeWallet());
      await authService.logOut();
      cache.put("user", null);
      yield LoggedOut();
    }
    //V2 Update
    else if (event is ConfirmPhoneCodeEvent) {
      User user = authService.currentUser();
      yield WaitingLogin(message: "Confirming code");
      var result =
          await apiService.confirmCode(uid: user.uid, code: event.code);
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
      locator<NavigationService>().pushReplaceNavigateToWidget(
        getPageRoute(
          VehicleRegistrationScreen(
            fromHomeScreen: true,
          ),
          RouteSettings(name: "CASH-IN"),
        ),
      );
    }
    //V2 Update
    else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      User user = await authService.loginGoogle();
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
      } else
        yield LoggedOut();
    } else if (event is LogInEmailEvent) {
      yield LoginInProgress();
      User user =
          await authService.signInWithEmail(event.email, event.password);
      if (user != null) {
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
          user = await authService.signInWithEmail(
              event.payload.email, event.payload.password);
        }
        var userFromApi =
            (await apiService.checkExistence(uid: user.uid)).body["data"];
        userData = CSUser.fromJson(userFromApi);
        yield checkUserDataForMissingInfo(user: userData);
      } else
        print(result.statusCode);
    }
  }

  LoginState checkUserDataForMissingInfo({CSUser user}) {
    LoginState result;
    if (user.phoneNumber == null) {
      setPushTokenCache();
      result = ShowPhoneNumberInputScreen();
    }
    // else if (user.vehicles.length == 0) {
    //   var userSettings = cache.get(user.uid);
    //   if (userSettings == null) {
    //     cache.put(user.uid, {"skipVehicle": false});
    //     setPushTokenCache();
    //     result = ShowVehicleRegistration();
    //   } else {
    //     if (userSettings["skipVehicle"] == true) {
    //       setPushTokenCache();
    //       startRepos(uid: user.uid);
    //       navService.pushReplaceNavigateTo(DashboardRoute);
    //     } else {
    //       result = ShowVehicleRegistration();
    //     }
    //   }
    // }
    else {
      setPushTokenCache();
      startRepos(uid: user.uid);
      navService.pushReplaceNavigateTo(DashboardRoute);
    }
    return result;
  }

  setPushTokenCache() async {
    String pushToken = locator<PushMessagingService>().token;
    User currentUser = locator<AuthService>().currentUser();
    await locator<ApiService>()
        .registerDevice(uid: currentUser.uid, token: pushToken);
  }

  showCodeGenerationErrorDialog() {
    showDialog(
        context: navService.navigatorKey.currentContext,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.error,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                    Text(
                      "Error generating code, please try again.",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    navService.goBack();
                    navService.navigatorKey.currentContext
                        .bloc<LoginBloc>()
                        .add(LoginStartEvent());
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  startRepos({@required String uid}) {
    navService.navigatorKey.currentContext.bloc<UserRepoBloc>().add(InitializeUserRepo(uid: uid));
    navService.navigatorKey.currentContext.bloc<VehicleRepoBloc>().add(InitializeVehicleRepo(uid: uid));
    navService.navigatorKey.currentContext.bloc<NotificationBloc>().add(InitializeNotificationRepo(uid: uid));
    navService.navigatorKey.currentContext.bloc<WalletBloc>().add(InitializeWallet(uid: uid));
  }

  stopRepos() {
    navService.navigatorKey.currentContext.bloc<UserRepoBloc>().add(DisposeUserRepo());
    navService.navigatorKey.currentContext.bloc<VehicleRepoBloc>().add(DisposeVehicleRepo());
    navService.navigatorKey.currentContext.bloc<NotificationBloc>().add(DisposeNotificationRepo());
    navService.navigatorKey.currentContext.bloc<WalletBloc>().add(DisposeWallet());
  }
}
