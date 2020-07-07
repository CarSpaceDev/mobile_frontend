import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/screens/login/LandingScreen.dart';
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
    return BlocProvider(
      create: (BuildContext context) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) async {
        if (state is LoginStartState) {
          var currentUser = await Provider.of<AuthService>(context, listen: false).currentUser();
          if (currentUser != null)
            context.bloc<LoginBloc>().add(LoggedInEvent());
          else
            context.bloc<LoginBloc>().add(NoSessionEvent());
        } else if (state is LoggedIn) {
          print("Logged in");
          Provider.of<GlobalData>(context, listen: false).user = state.user;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(),
            ),
          );
        }
      },
          builder: (context, state) {
        if (state is LoginInitialState) {
          context.bloc<LoginBloc>().add(LoginStartEvent());
          return LoadingScreen(
            prompt: 'Starting Initialization',
          );
        } else if (state is LoggedOut) {
          return LandingScreen();
        } else if (state is LoginInProgress) {
          return LoadingScreen(
            prompt: 'Logging in',
          );
        } else if (state is AuthorizationSuccess) {
          return LoadingScreen(
            prompt: 'Getting user data',
          );
        }
        return LoadingScreen(
          prompt: 'Checking for sessions',
        );
      }),
    );
  }
}
