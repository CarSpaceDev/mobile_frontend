import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/screens/login/EulaScreen.dart';
import 'package:carspace/screens/login/GoogleEula.dart';
import 'package:carspace/screens/login/LandingScreen.dart';
import 'package:carspace/screens/login/RegistrationScreen.dart';
import 'package:carspace/screens/login/ReturnScreen.dart';
import 'package:carspace/screens/login/TestScreen.dart';
import 'package:carspace/screens/prompts/LoadingScreen.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../HomeScreen.dart';
import 'login_bloc.dart';

class LoginBlocHandler extends StatefulWidget {
  @override
  _LoginBlocHandlerState createState() => _LoginBlocHandlerState();
}

class _LoginBlocHandlerState extends State<LoginBlocHandler> {
  @override
  Widget build(BuildContext context) {
    var globalData = Provider.of<GlobalData>(context, listen: false);
    return BlocProvider(
      create: (BuildContext context) => LoginBloc(),
      child:
          BlocConsumer<LoginBloc, LoginState>(listener: (context, state) async {
        if (state is LoginStartState) {
          var currentUser =
              await Provider.of<AuthService>(context, listen: false)
                  .currentUser();
          if (currentUser != null)
            context.bloc<LoginBloc>().add(LoggedInEvent());
          else
            context.bloc<LoginBloc>().add(NoSessionEvent());
        } else if (state is LoggedIn) {
          print("Logged in");
          Provider.of<GlobalData>(context, listen: false).user = state.user;
        } else if (state is GoogleToEulaState) {
          print("Logged in");
          Provider.of<GlobalData>(context, listen: false).user = state.user;
        }
      }, builder: (context, state) {
        if (state is LoginInitialState) {
          context.bloc<LoginBloc>().add(LoginStartEvent());
          return LoadingScreen(
            prompt: 'Starting Initialization',
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
          return LandingScreen();
        } else if (state is LoggedIn)
          return HomeScreen();
        else if (state is GoogleToEulaState)
          return GoogleEula();
        else if (state is NavToEula)
          return EulaScreen();
        else if (state is NavToRegister)
          return RegistrationScreen();
        else if (state is NavToTestPage) {
          globalData.heldEmail = state.email;
          globalData.heldFirstName = state.firstName;
          globalData.heldLastName = state.lastName;
          return TestScreen();
        } else if (state is NavToLandingPage)
          return LandingScreen();
        else if (state is NavToReturnScreen) {
          globalData.heldEmail = state.email;
          globalData.heldFirstName = state.firstName;
          globalData.heldLastName = state.lastName;
          return ReturnScreen();
        }
        return LoadingScreen(
          prompt: 'Checking for sessions',
        );
      }),
    );
  }
}
