import 'dart:async';

import 'package:carspace/blocs/mqtt/mqtt_bloc.dart';
import 'package:carspace/model/CSUser.dart';
import 'package:carspace/repo/lotRepo/lot_repo_bloc.dart';
import 'package:carspace/repo/notificationRepo/notification_bloc.dart';
import 'package:carspace/repo/reservationRepo/reservation_repo_bloc.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/screens/Login/RegistrationScreen.dart';
import 'package:carspace/screens/Dashboard/PartnerDashboard.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/PushMessagingService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState());
  final AuthService _authService = locator<AuthService>();
  final ApiService _apiService = locator<ApiService>();
  final NavigationService _navService = locator<NavigationService>();
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final cache = Hive.box("localCache");
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    //V2 Update
    if (event is LoginStartEvent) {
      User user = _authService.currentUser();
      if (user != null) {
        try {
          DocumentSnapshot userFromApi = await _firebase.collection("users").doc(user.uid).get();
          if (userFromApi.exists) {
            yield checkUserDataForMissingInfo(user: CSUser.fromDoc(userFromApi));
          } else {
            yield ShowEulaScreen();
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
        await _authService.logOut();
        yield LoggedOut();
      }
    } else if (event is NavigateToEulaEvent) {
      yield ShowEulaScreen();
    }
    //V2 Update
    else if (event is GeneratePhoneCodeEvent) {
      User user = _authService.currentUser();
      yield WaitingLogin(message: "Generating code");
      try {
        var result = await _apiService.generateCode(uid: user.uid, phoneNumber: event.phoneNumber);
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
      await _authService.logOut();
      cache.put("user", null);
      yield LoggedOut();
    }
    //V2 Update
    // else if (event is SkipVehicleAddEvent) {
    //   User user = _authService.currentUser();
    //   cache.put(user.uid, {"skipVehicle": true});
    //   setPushTokenCache();
    //   startRepos(user:user);
    //   _navService.pushReplaceNavigateTo(DashboardRoute);
    // }
    //V2 Update
    else if (event is LogoutEvent) {
      yield WaitingLogin(message: "Please wait");
      await _apiService.unregisterDevice(
          uid: _authService.currentUser().uid, token: locator<PushMessagingService>().token);
      stopRepos();
      await _authService.logOut();
      cache.put("user", null);
      yield LoggedOut();
    }
    //V2 Update
    else if (event is ConfirmPhoneCodeEvent) {
      User user = _authService.currentUser();
      yield WaitingLogin(message: "Confirming code");
      var result = await _apiService.confirmCode(uid: user.uid, code: event.code);
      if (result.statusCode == 200) {
        DocumentSnapshot userFromApi = await _firebase.collection("users").doc(user.uid).get();
        if (userFromApi.exists) {
          yield checkUserDataForMissingInfo(user: CSUser.fromDoc(userFromApi));
        }
      } else {
        yield LoginError(message: result.error.toString());
      }
    }
    //V2 Update
    else if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      print("Logging in via google");
      User user = await _authService.loginGoogle();
      print("User");
      if (user != null) {
        DocumentSnapshot userFromApi = await _firebase.collection("users").doc(user.uid).get();
        if (userFromApi.exists) {
          yield checkUserDataForMissingInfo(user: CSUser.fromDoc(userFromApi));
        } else {
          yield ShowEulaScreen();
        }
      } else {
        yield LoggedOut();
      }
    } else if (event is LogInEmailEvent) {

      yield LoginInProgress();
      User user = await _authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        DocumentSnapshot userFromApi = await _firebase.collection("users").doc(user.uid).get();
        if (userFromApi.exists) {
          yield checkUserDataForMissingInfo(user: CSUser.fromDoc(userFromApi));
        } else {
          yield ShowEulaScreen();
        }
      } else
        yield LoggedOut();
    } else if (event is SubmitRegistrationEvent) {
      yield WaitingLogin(message: "Creating your account");
      var result = await _apiService.registerUser(event.payload.toJson());
      if (result.statusCode == 201) {
        yield LoginInProgress();
        User user = _authService.currentUser();
        if (user == null) {
          user = await _authService.signInWithEmail(event.payload.email, event.payload.password);
        }
        DocumentSnapshot userFromApi = await _firebase.collection("users").doc(user.uid).get();
        if (userFromApi.exists) {
          yield checkUserDataForMissingInfo(user: CSUser.fromDoc(userFromApi));
        }
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
      startRepos(user:user);
      if(user.partnerAccess > 110)
        _navService.pushReplaceNavigateToWidget(
          getPageRoute(
            PartnerDashboard(),
            RouteSettings(name: "PARTNER DASHBOARD"),
          ),
        );
      else
      _navService.pushReplaceNavigateTo(DashboardRoute);
    }
    return result;
  }

  setPushTokenCache() async {
    String pushToken = locator<PushMessagingService>().token;
    User currentUser = locator<AuthService>().currentUser();
    await locator<ApiService>().registerDevice(uid: currentUser.uid, token: pushToken);
  }

  showCodeGenerationErrorDialog() {
    showDialog(
        context: _navService.navigatorKey.currentContext,
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
                    _navService.goBack();
                    _navService.navigatorKey.currentContext.bloc<LoginBloc>().add(LoginStartEvent());
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  startRepos({@required CSUser user}) {
    _navService.navigatorKey.currentContext.bloc<UserRepoBloc>().add(InitializeUserRepo(uid: user.uid));
    _navService.navigatorKey.currentContext.bloc<VehicleRepoBloc>().add(InitializeVehicleRepo(uid: user.uid));
    _navService.navigatorKey.currentContext.bloc<NotificationBloc>().add(InitializeNotificationRepo(uid: user.uid));
    _navService.navigatorKey.currentContext.bloc<ReservationRepoBloc>().add(InitializeReservationRepo(uid: user.uid, isPartner: user.partnerAccess>110));
    _navService.navigatorKey.currentContext.bloc<WalletBloc>().add(InitializeWallet(uid: user.uid));
    _navService.navigatorKey.currentContext.bloc<MqttBloc>().add(InitializeMqtt());
    if(user.partnerAccess>110)
    _navService.navigatorKey.currentContext.bloc<LotRepoBloc>().add(InitializeLotRepo(uid: user.uid));
  }

  stopRepos() {
    _navService.navigatorKey.currentContext.bloc<UserRepoBloc>().add(DisposeUserRepo());
    _navService.navigatorKey.currentContext.bloc<VehicleRepoBloc>().add(DisposeVehicleRepo());
    _navService.navigatorKey.currentContext.bloc<NotificationBloc>().add(DisposeNotificationRepo());
    _navService.navigatorKey.currentContext.bloc<ReservationRepoBloc>().add(DisposeReservationRepo());
    _navService.navigatorKey.currentContext.bloc<WalletBloc>().add(DisposeWallet());
    _navService.navigatorKey.currentContext.bloc<MqttBloc>().add(DisposeMqtt());
    _navService.navigatorKey.currentContext.bloc<LotRepoBloc>()?.add(DisposeLotRepo());
  }
}
