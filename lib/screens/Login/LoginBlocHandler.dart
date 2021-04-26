import 'package:carspace/screens/Login/EulaScreen.dart';
import 'package:carspace/screens/Login/LoginScreen.dart';
import 'package:carspace/screens/Login/PhoneNumberInputScreen.dart';
import 'package:carspace/screens/Login/RegistrationScreen.dart';
import 'package:carspace/screens/Login/ReturnScreen.dart';
import 'package:carspace/screens/DriverScreens/Vehicles/VehicleRegistrationScreen.dart';
import 'package:carspace/screens/prompts/ErrorScreen.dart';
import 'package:carspace/screens/prompts/LoadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/login/login_bloc.dart';
import 'PhoneCodeConfirmScreen.dart';

class LoginBlocHandler extends StatefulWidget {
  @override
  _LoginBlocHandlerState createState() => _LoginBlocHandlerState();
}

class _LoginBlocHandlerState extends State<LoginBlocHandler> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) async {},
        builder: (context, state) {
          //V2 Update
          if (state is LoginInitialState) {
            context.bloc<LoginBloc>().add(LoginStartEvent());
            return LoadingScreen(
              prompt: 'Checking for sessions',
            );
          } else if (state is LoginInProgress) {
            return LoadingScreen(
              prompt: 'Logging in',
            );
          } else if (state is AuthorizationSuccess) {
            return LoadingScreen(
              prompt: 'Getting user data',
            );
          } else if (state is LoggedOut) {
            return LoginScreen();
          } else if (state is GoogleToEulaState)
            return EulaScreen();
          else if (state is NavToEula) {
            return EulaScreen();
          }
          //V2 Update
          else if (state is ShowEulaScreen) {
            return EulaScreen();
          }
          //V2 Update
          else if (state is ShowPhoneNumberInputScreen) {
            return PhoneNumberInputScreen();
          }
          //V2 Update
          else if (state is ShowPhoneCodeConfirmScreen) {
            return PhoneCodeConfirmScreen();
          }
          //V2 Update
          else if (state is WaitingLogin) {
            return LoadingScreen(
              prompt: state.message,
            );
          }
          //V2 Update
          else if (state is LoginError) {
            return ErrorScreen(
              prompt: state.message,
              showButtons: true,
            );
          }
          //V2 Update
          else if (state is ShowVehicleRegistration) {
            return VehicleRegistrationScreen(fromHomeScreen: state.fromHomeScreen);
          } else if (state is NavToRegister)
            return RegistrationScreen();
          else if (state is NavToLandingPage)
            return LoginScreen();
          else if (state is NavToReturnScreen) {
            // globalData.heldEmail = state.email;
            // globalData.heldFirstName = state.firstName;
            // globalData.heldLastName = state.lastName;
            return ReturnScreen();
          }
          return LoadingScreen(
            prompt: 'Checking for sessions',
          );
        });
  }
}
